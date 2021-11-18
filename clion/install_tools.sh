#! /bin/bash

# enable clion support
# see https://github.com/JetBrains/clion-remote

function run_apt()
{
    apt-get update \
    && apt-get install --no-install-recommends -y \
    openssh-server rsync\
    gdb valgrind \
    && apt-get clean

    echo 'Subsystem sftp /usr/lib/openssh/sftp-server' >> /etc/ssh/sshd_config_test_clion
}

function run_dnf()
{
    dnf install -y openssh-server rsync gdb
    # valgrind.x86_64 ??
    ssh-keygen -A

    echo 'Subsystem sftp /usr/libexec/openssh/sftp-server' >> /etc/ssh/sshd_config_test_clion
}

#  echo 'LogLevel DEBUG2'; \
( \
  echo 'PermitRootLogin yes'; \
  echo 'PasswordAuthentication yes'; \
) > /etc/ssh/sshd_config_test_clion
mkdir -p /run/sshd

if [ -f /etc/os-release ]
then
    . /etc/os-release
else
    echo "ERROR: I need the file /etc/os-release to determine what my distribution is..."
    # If you want, you can include older or distribution specific files here...
    exit
fi

case $ID_LIKE in
    debian)
	run_apt
	;;
    fedora)
	run_dnf
	;;
    *)
	echo "Unkown OS : like=${ID_LIKE} name=${NAME} id=${ID}"
	exit 1
	;;
esac
