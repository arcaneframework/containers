# Dockerconfig
UID=$(shell id --user)
GID=$(shell id --group)
DOCKER_CMD=podman

BASEIMAGE=ubuntu:22.04
IMAGE_NAME=spack-ubuntu
REPO=ghcr.io/arcaneframework
RECIPES_BRANCH=main
SPACK_VERSION=0.19.0

IMAGE_VERSION:= $(shell date '+%Y-%m-%d')

.phony: build

.DEFAULT_GOAL := build

build: Dockerfile Makefile
	${DOCKER_CMD} build --format=docker --build-arg UID=${UID} --build-arg GID=${GID} --build-arg BASEIMAGE=${BASEIMAGE} --build-arg RECIPES_BRANCH=${RECIPES_BRANCH} --build-arg SPACK_VERSION=${SPACK_VERSION} -t ${REPO}/${IMAGE_NAME}:${IMAGE_VERSION} -t ${REPO}/${IMAGE_NAME}:latest .
