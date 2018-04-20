package main

import (
    "bytes"
    "encoding/json"
    "errors"
    "log"
    "io/ioutil"
    "net/http"
    "os"
    "time"

    yaml "gopkg.in/yaml.v2"
    apiv1 "k8s.io/client-go/pkg/api/v1"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/client-go/kubernetes"
    _ "k8s.io/client-go/plugin/pkg/client/auth/gcp"
    "k8s.io/client-go/rest"
)

type AssignmentRequest struct {
    Student             string `json:"student"`
    AssignmentFilename  string `json:"assignmentFilename"`
    Path                string `json:"path"`
    CourseId            string `json:"courseId"`
    AssignmentId        string `json:"assignmentId"`
}

type Course struct {
    Name        string `yaml:"name"`
    Repo        string `yaml:"repo"`
    Instructor  string `yaml:"instructor"`
}

type Courses struct {
    Courses     []Course `yaml:"courses"`
}

func main() {
    log.Printf("Will set proxy up\n")
    server := setupServer()
    log.Printf("Proxy setup complete\n")

    log.Printf("Will start listening for events\n")
    err := server.ListenAndServe()
    if  err != nil {
        log.Printf("Proxy exited with message %s\n", err)
        os.Exit(1)
    }
}

func setupServer() *http.Server {
    mux := http.NewServeMux()

    if os.Getenv("PROXY_PORT") == "" {
        log.Printf("No PROXY_PORT specified, will exit\n")
        os.Exit(1)
    }

    server := http.Server{
        Addr:    ":" + os.Getenv("PROXY_PORT"),
        Handler: mux,
    }

    mux.HandleFunc("/assignment-submitted", handleAssignmentSubmission)

    return &server
}

func dispatchRequest(req *http.Request, client *http.Client) (*http.Response, error) {
    resp, err := client.Do(req)

    retry_counter := 20
    for err != nil && retry_counter > 0 {
        resp, err = client.Do(req)
        if err != nil {
            log.Printf("Recipient not ready yet, waiting...\n")
            time.Sleep(time.Second * 3)
            retry_counter--
        }
    }

    if err != nil {
        return nil, err
    }

    return resp, nil
}

func handleAssignmentSubmission(w http.ResponseWriter, r *http.Request) {
    log.Printf("Will handle request to %s\n", r.URL.String())
    if r.Body == nil {
        log.Printf("Request to %s missing body\n", r.URL.String())
        http.Error(w, "MISSING_BODY", 400)
        return
    }

    assignmentMessage := &AssignmentRequest{}
    err := json.NewDecoder(r.Body).Decode(assignmentMessage)
    if err != nil {
        log.Printf("Could not parse request body: %s\n", err.Error())
        http.Error(w, err.Error(), 500)
        return
    }

    log.Printf("Student %s just submitted an assignment\n", assignmentMessage.Student)

    targetAddr, err := getPodForCourse(assignmentMessage.CourseId)
    if err != nil {
        log.Printf("Could not get pod for course %s: %s\n", assignmentMessage.CourseId, err.Error())
        http.Error(w, err.Error(), 500)
        return
    }

    body, err := json.Marshal(*assignmentMessage)
    if err != nil {
        log.Printf("Could not marshal request body: %s\n", err.Error())
        http.Error(w, err.Error(), 500)
        return
    }

    req, err := http.NewRequest("POST", targetAddr + "/grade", bytes.NewBuffer(body))
    if err != nil {
        log.Printf("Could not create request for instructor pod: %s\n", err.Error())
        http.Error(w, err.Error(), 500)
        return
    }

    req.Header.Set("Content-Type", "application/json")

    client := &http.Client{}

    resp, err := dispatchRequest(req, client)
    if err != nil {
        log.Printf("Could not send request to instructor pod: %s\n", err.Error())
        http.Error(w, err.Error(), 500)
        return
    }

    responseBody, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        log.Printf("Could not read response body from instructor pod: %s\n", err.Error())
        http.Error(w, err.Error(), 500)
        return
    }

    resp.Body.Close()

    w.Header().Set("Content-Type", "application/json")
    w.Write(responseBody)
    return
}

func getPodForCourse(courseId string) (string, error) {
    port := os.Getenv("INSTRUCTOR_PORT")
    if port == "" {
        return "", errors.New("INSTRUCTOR_PORT has not been specified")
    }

    namespace := os.Getenv("HUB_NAMESPACE")
    if namespace == "" {
        return "", errors.New("HUB_NAMESPACE has not been specified")
    }

    config, err := rest.InClusterConfig()
    if err != nil {
        log.Printf("Could not get in-cluster config: %s\n", err.Error())
        return "", err
    }

    clientSet, err := kubernetes.NewForConfig(config)
    if err != nil {
        log.Printf("Could not create client set: %s\n", err.Error())
        return "", err
    }

    coursesFile, err := os.Open("/courses.yaml")
    if err != nil {
        log.Printf("Error while opening courses file: %s\n", err.Error())
        return "", err
    }

    instructor := ""
    coursesDecoder := yaml.NewDecoder(coursesFile)

    courses := Courses{}
    err = coursesDecoder.Decode(&courses)
    if err != nil {
        log.Printf("Error while looking for course: %s\n", err.Error())
        return "", err
    }

    for _, course := range(courses.Courses) {
        if course.Name == courseId {
            instructor = course.Instructor
            break
        }
    }

    if instructor == "" {
        log.Println("Empty instructor for course")
        return "", errors.New("No instructor")
    }

    podsClient := clientSet.CoreV1().Pods(namespace)
    podId := "jupyter-" + instructor

    var instructorPod *apiv1.Pod
    for ;; {
        instructorPod, err = podsClient.Get(podId, metav1.GetOptions{})

        if err == nil {
            if instructorPod.Status.Phase == apiv1.PodRunning {
                break
            }
        } else {
            log.Printf("Instructor pod not found, will spawn\n")

            hubUrl := os.Getenv("JUPYTERHUB_API_URL")
            if hubUrl == "" {
                log.Printf("JUPYTERHUB_API_URL not provided\n")
                return "", errors.New("JUPYTERHUB_API_URL not provided")
            }

            req, err := http.NewRequest("POST", hubUrl + "/users/" + instructor + "/server", bytes.NewBuffer([]byte("")))
            if err != nil {
                log.Printf("Could not create request for instructor pod: %s\n", err.Error())
                return "", err
            }

            req.Header.Set("Authorization", "token " + os.Getenv("JUPYTERHUB_API_TOKEN"))

            client := &http.Client{}

            resp, err := client.Do(req)
            if err != nil {
                log.Printf("Could not send spawn request to hub: %s\n", err.Error())
                return "", err
            }

            if !(resp.StatusCode == 201 || resp.StatusCode == 202) {
                log.Printf("Could not spawn instructor server, %d\n", resp.StatusCode)
                return "", errors.New("Could not spawn instructor server")
            }
        }

        time.Sleep(time.Second * 5)
    }

    podAddr := instructorPod.Status.PodIP
    return "http://" + podAddr + ":" + port, nil
}
