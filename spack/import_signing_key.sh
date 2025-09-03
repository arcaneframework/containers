#! /usr/bin/bash

SPACKHOME=/spack
export GNUPGHOME=${SPACKHOME}/opt/spack/gpg

. ${SPACKHOME}/share/spack/setup-env.sh
spack gpg init
spack gpg list 2> /dev/null

gpg --import "$1"
for fpr in $(gpg --no-tty --list-keys --with-colons  | awk -F: '/fpr:/ {print $10}' | sort -u); do
    echo -e "5\ny\n" |  gpg --no-tty --command-fd 0 --expert --edit-key $fpr trust;
done
