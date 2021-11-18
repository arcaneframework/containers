ARG BASEIMAGE=arcaneframework/alien-base:ubuntu20.04
FROM $BASEIMAGE
LABEL maintainer.email=<cedric.chevalier@cea.fr>

ARG UID=1000
ARG GID=100

USER root

RUN ( ( getent group $GID ) ||  groupadd --gid $GID user ) \
    &&( ( getent passwd $UID ) || useradd --gid $GID --uid $UID user ) \
    && yes weakpassword | passwd $(getent passwd $UID | cut -f1 -d:)

ADD install_tools.sh .
# enable clion support
# see https://github.com/JetBrains/clion-remote
RUN ./install_tools.sh $UID $GID

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config_test_clion"]
