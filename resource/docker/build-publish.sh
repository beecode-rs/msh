#!/bin/bash

DOCKER_IMG_HOST=milosbugarinovic
IMG_BASE_NAME=msh-lib-base
IMG_VERSION=node18.17.0-alpine3.18

docker build -f ./${IMG_BASE_NAME}_${IMG_VERSION}.dockerfile -t ${DOCKER_IMG_HOST}/${IMG_BASE_NAME}:latest -t ${DOCKER_IMG_HOST}/${IMG_BASE_NAME}:${IMG_VERSION} .

docker push ${DOCKER_IMG_HOST}/${IMG_BASE_NAME}:${IMG_VERSION}
docker push ${DOCKER_IMG_HOST}/${IMG_BASE_NAME}:latest
