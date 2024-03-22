#!/bin/bash

DOCKER_IMG_HOST=milosbugarinovic
IMG_BASE_NAME=msh-lib-base
IMG_VERSION=node20.11.1-alpine3.19

docker build -f ./${IMG_BASE_NAME}_${IMG_VERSION}.dockerfile -t ${DOCKER_IMG_HOST}/${IMG_BASE_NAME}:latest -t ${DOCKER_IMG_HOST}/${IMG_BASE_NAME}:${IMG_VERSION} .

docker push ${DOCKER_IMG_HOST}/${IMG_BASE_NAME}:${IMG_VERSION}
docker push ${DOCKER_IMG_HOST}/${IMG_BASE_NAME}:latest
