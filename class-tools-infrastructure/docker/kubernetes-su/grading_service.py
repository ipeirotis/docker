from flask import Flask, request, Response, jsonify
import hashlib
import os
import shutil
import subprocess
import textwrap
from time import sleep

app = Flask(__name__)

def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

@app.route("/grade", methods = ['POST'])
def run_grader():
    body = request.get_json()

    # extract submission info
    student = body['student'] if 'student' in body else None
    assignment = body['assignmentId'] if 'assignmentId' in body else None
    course = body['courseId'] if 'courseId' in body else None

    try:
        # collect student submission for this assignment
        collect_proc = subprocess.Popen(["nbgrader", "collect", "--student={}".format(student),
            "--assignment={}".format(assignment), "--update"], stdout=subprocess.PIPE)
        while collect_proc.poll() == None:
            sleep(0.5)

        # run nbgrader autograde for this assignment
        autograde_proc = subprocess.Popen(["nbgrader", "autograde", "--Autograde.permissions=644",
            "--student={}".format(student), "--assignment={}".format(assignment), "--create"],
            stdout=subprocess.PIPE)
        while autograde_proc.poll() == None:
            sleep(0.5)

        # generate feedback for the autograded assignment
        feedback_proc = subprocess.Popen(["nbgrader", "feedback", "--student={}".format(student),
            "--assignment={}".format(assignment)], stdout=subprocess.PIPE)
        while feedback_proc.poll() == None:
            sleep(0.5)

        feedback_dir = '/home/{username}/notebooks/{course}/feedback/{student}/{assignment}/'.format(username=os.getenv('JUPYTERHUB_USER'),
                course=course, student=student, assignment=assignment)
        feedback_file_path = feedback_dir + '{assignment_no_spaces}.html'.format(assignment_no_spaces=assignment.replace(' ', '_'))
        feedback_hash = md5(feedback_file_path)

        exchange_feedback_root = '/home/{username}/assignments/feedback/'.format(username=os.getenv('JUPYTERHUB_USER'))
        target_dir = exchange_feedback_root + '/'.join(textwrap.wrap(feedback_hash[:-1], 4))
        stored_feedback_path = '/'.join(textwrap.wrap(feedback_hash, 4))
        target_url = exchange_feedback_root + stored_feedback_path

        if not os.path.exists(target_dir):
            os.makedirs(target_dir)

        # move the generated feedback into the shared storage
        if shutil.move(feedback_file_path, target_url) != target_url:
            raise SystemError('Could not move feedback file to target')

        # delete the existing feedback folder
        shutil.rmtree(feedback_dir)

        # add the path to the generated feedback to the response body
        return jsonify({'path': stored_feedback_path})
    except Exception as e:
        print("Failed: ", str(e))
        return Response(response = "Something went wrong during grading", status = '500')

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=51017)
