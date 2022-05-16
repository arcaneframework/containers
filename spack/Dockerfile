ARG BASEIMAGE=ecpe4s/rhel8-runner-x86_64

FROM $BASEIMAGE

ARG SPACK_VERSION=0.17.2
ARG RECIPES_BRANCH=main

ARG UID=1000
ARG GID=100

RUN ( ( getent group $GID ) ||  groupadd --gid $GID user ) \
    &&( ( getent passwd $UID ) || useradd --gid $GID --uid $UID user )

RUN mkdir -p /spack /recipes /home/user && useradd spack && chown -R user: /spack /recipes /home/user

USER user

SHELL ["/bin/bash", "-c"]

# Download last release of spack
RUN curl -L https://github.com/spack/spack/releases/download/v${SPACK_VERSION}/spack-${SPACK_VERSION}.tar.gz | tar xz -C /spack --strip-components=1 && \
    source /spack/share/spack/setup-env.sh

# Get arcane recipes
RUN curl -L https://github.com/arcaneframework/spack_recipes/archive/refs/heads/${RECIPES_BRANCH}.tar.gz | tar xz -C /recipes --strip-components 1

COPY --chown=user envs /tmp/envs

# Define and compile dev-tools environment
RUN source /spack/share/spack/setup-env.sh && \
    spack env create dev-tools /tmp/envs/dev-tools/spack.yaml && \
    spack env activate dev-tools && \
    spack concretize -f && spack install --fail-fast

# setup our recipes
RUN source /spack/share/spack/setup-env.sh && \
    spack repo add --scope site /recipes

# Define and compile an alien environment
RUN source /spack/share/spack/setup-env.sh && \
    spack env create alien /tmp/envs/alien/spack.yaml && \
    spack env activate alien && \
    spack concretize -f && spack install --fail-fast

# Define and compile an arcane environment
RUN source /spack/share/spack/setup-env.sh && \
    spack env create arcane /tmp/envs/arcane/spack.yaml && \
    spack env activate arcane && \
    spack concretize -f && spack install --fail-fast

# Define and compile an arcane and alien environment
RUN source /spack/share/spack/setup-env.sh && \
    spack env create arcane_alien /tmp/envs/all/spack.yaml && \
    spack env activate arcane_alien && \
    spack concretize -f && spack install --fail-fast

RUN rm -rf /tmp/* || true
