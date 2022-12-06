#! /usr/bin/bash

install_apt() {
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y build-essential ca-certificates coreutils curl environment-modules gfortran git gpg lsb-release python3 python3-distutils python3-venv unzip zip curl
apt clean
rm -rf /var/lib/apt/lists/*
}

install_dnf()
{
    dnf -y update
    dnf -y group install "Development Tools"
    dnf -y install curl gnupg2 python3 python3-pip python3-setuptools
    dnf -y install bash
    dnf clean all
}

if [ "$(type apt)" ]; then
    install_apt;
elif [ "$(type dnf)" ]; then
    install_dnf;
fi
