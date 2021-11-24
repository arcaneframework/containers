# Dockerconfig
UID=$(shell id --user)
GID=$(shell id --group)
DOCKER_CMD=podman

BASEIMAGE=ecpe4s/rhel8-runner-x86_64
IMAGE_NAME=spack-rhel8
REPO=ghcr.io/arcaneframework

IMAGE_VERSION:= $(shell date '+%Y-%m-%d')

.phony: build

.DEFAULT_GOAL := build

build: Dockerfile Makefile
	${DOCKER_CMD} build --format=docker --build-arg UID=${UID} --build-arg GID=${GID} --build-arg BASEIMAGE=${BASEIMAGE} -t ${REPO}/${IMAGE_NAME}:${IMAGE_VERSION} -t ${REPO}/${IMAGE_NAME}:latest .

