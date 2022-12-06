#! /usr/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y build-essential ca-certificates coreutils curl environment-modules gfortran git gpg lsb-release python3 python3-distutils python3-venv unzip zip curl
apt clean
rm -rf /var/lib/apt/lists/*
