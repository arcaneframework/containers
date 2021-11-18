# Dockerconfig
UID=$(shell id --user)
GID=$(shell id --group)
DOCKER_CMD=podman

IMAGE_BASE_NAME=alien-base
IMAGE_VERSION=ubuntu20.04
REPO=ghcr.io/arcaneframework
SSH_PORT=2004

.phony: run build_clion

.DEFAULT_GOAL := run

build_clion: Dockerfile Makefile
	${DOCKER_CMD} build --build-arg UID=${UID} --build-arg GID=${GID} --build-arg BASEIMAGE=${REPO}/${IMAGE_BASE_NAME}:${IMAGE_VERSION} -t clion-${IMAGE_BASE_NAME}:${IMAGE_VERSION} .

run: build_clion
	${DOCKER_CMD} run --rm -d --image-volume=tmpfs --cap-add sys_ptrace -p 127.0.0.1:${SSH_PORT}:22 clion-${IMAGE_BASE_NAME}:${IMAGE_VERSION}
