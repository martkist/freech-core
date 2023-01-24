#!/usr/bin/env bash

DOCKER_TAG=${DOCKER_TAG:-`git rev-parse --short HEAD`}

docker build --pull --build-arg TAG=$DOCKER_TAG -t $DOCKER_IMAGE:$DOCKER_TAG .
