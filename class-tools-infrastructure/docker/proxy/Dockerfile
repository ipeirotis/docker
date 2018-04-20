FROM golang:1.8-alpine3.6

ARG CODE_PATH

WORKDIR /app

RUN mkdir -p go/src/grader-proxy

COPY proxy/main.go /app/go/src/grader-proxy/
COPY proxy/glide.yaml /app/go/src/grader-proxy/
COPY proxy/glide.lock /app/go/src/grader-proxy/
COPY docker/kubernetes-su/courses.yaml /

RUN apk add --update git glide bash

ENV GOPATH=/app/go

RUN cd /app/go/src/grader-proxy && \
    glide install -v && \
    go install -v . && \
    rm -rf /app/go/src/grader-proxy/vendor && \
    apk del git glide && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.glide

EXPOSE 51017

ENV PROXY_PORT=51017
ENV INSTRUCTOR_PORT=51017

ENTRYPOINT ["/app/go/bin/grader-proxy"]
