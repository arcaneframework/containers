ARG BASEIMAGE=ecpe4s/rhel8-runner-x86_64

FROM $BASEIMAGE

ARG SPACK_VERSION=0.17.0
ARG RECIPES_BRANCH=main

ARG UID=1000
ARG GID=100

RUN ( ( getent group $GID ) ||  groupadd --gid $GID user ) \
    &&( ( getent passwd $UID ) || useradd --gid $GID --uid $UID user )

RUN mkdir -p /spack /recipes /home/user && useradd spack && chown -R user: /spack /recipes /home/user

USER user

RUN ls -l /home/

SHELL ["/bin/bash", "-c"]

# Download last release of spack and configure it to use buildcache
RUN curl -L https://github.com/spack/spack/releases/download/v${SPACK_VERSION}/spack-${SPACK_VERSION}.tar.gz | tar xz -C /spack --strip-components=1 && \
    source /spack/share/spack/setup-env.sh && \
    spack mirror add --scope site E4S https://cache.e4s.io && \
    spack buildcache keys -it

# Load e4s spack config to optimize buildcache use
COPY --chown=user:user e4s-config-packages.yaml /spack/etc/spack/packages.yaml

# RUN spack config --scope site add packages:all:providers:mpi:[openmpi]

# Get arcane recipes
RUN curl -L https://github.com/arcaneframework/spack_recipes/archive/refs/heads/${RECIPES_BRANCH}.tar.gz | tar xz -C /recipes --strip-components 1

# setup our recipes
RUN source /spack/share/spack/setup-env.sh && \
    spack repo add --scope site /recipes

# Define and compile an alien environment
RUN source /spack/share/spack/setup-env.sh && \
    spack env activate -d /recipes/envs/alien && \
    spack concretize -f && spack install --fail-fast

# Define and compile an arcane environment
RUN source /spack/share/spack/setup-env.sh && \
    spack env activate -d /recipes/envs/arcane && \
    spack concretize -f && spack install --fail-fast

# Define and compile an arcane and alien environment
RUN source /spack/share/spack/setup-env.sh && \
    spack env activate -d /recipes/envs/all && \
    spack concretize -f && spack install --fail-fast
