#! /bin/bash

make IMAGE_BASE_NAME=alien-base IMAGE_VERSION=ubuntu20.04 SSH_PORT=2004 run
make IMAGE_BASE_NAME=spack-rhel8 IMAGE_VERSION=latest SSH_PORT=1083 run
