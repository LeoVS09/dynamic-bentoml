#!/usr/bin/env make

.PHONY: build push push-latest build-and-push

default: build-and-push

IMAGE_VERSION=0.13.1-py36
IMAGE_NAME=leovs09/dynamic-bentoml

# ---------------------------------------------------------------------------------------------------------------------
# DOCKER
# ---------------------------------------------------------------------------------------------------------------------

build-and-push: build push push-latest

build:
	docker build -t ${IMAGE_NAME}:${IMAGE_VERSION} .

push:
	docker push ${IMAGE_NAME}:${IMAGE_VERSION}

push-latest:
	docker tag ${IMAGE_NAME}:${IMAGE_VERSION} ${IMAGE_NAME}:latest
	docker push ${IMAGE_NAME}:latest