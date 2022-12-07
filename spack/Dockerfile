# syntax=docker/dockerfile:1
ARG BASEIMAGE=ubuntu:22.04

FROM $BASEIMAGE

ARG SPACK_VERSION=0.19.0
ARG RECIPES_BRANCH=main

ADD install_spack_deps.sh /tmp/

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked bash /tmp/install_spack_deps.sh

SHELL ["/bin/bash", "-c"]

# Download last release of spack
RUN mkdir -p /spack && \
    curl -L https://github.com/spack/spack/releases/download/v${SPACK_VERSION}/spack-${SPACK_VERSION}.tar.gz | tar xz -C /spack --strip-components=1 && \
    source /spack/share/spack/setup-env.sh && \
    spack config --scope site add 'packages:all:target:[x86_64]' && \
    spack compiler find

# Get arcane recipes
RUN mkdir -p recipes && \
    curl -L https://github.com/arcaneframework/spack_recipes/archive/refs/heads/${RECIPES_BRANCH}.tar.gz | tar xz -C /recipes --strip-components 1 && \
    source /spack/share/spack/setup-env.sh && \
    spack repo add --scope site /recipes

ADD import_signing_key.sh /tmp

RUN --mount=type=secret,id=signingkey,uid=1000 /tmp/import_signing_key.sh /run/secrets/signingkey

RUN --mount=type=cache,target=/buildcache,source=buildcache source /spack/share/spack/setup-env.sh && \
    spack mirror add cache /buildcache && \
    spack buildcache update-index -d /buildcache

# Define and compile an alien environment
RUN --mount=type=cache,target=/home/user/buildcache,source=buildcache source /spack/share/spack/setup-env.sh && \
    spack env create alien --without-view && \
    spack env activate alien && \
    spack add alien +hypre+petsc+xml+hdf5+move+ref ginkgo=omp trilinos=omp && \
    spack concretize -f && spack install --fail-fast

RUN --mount=type=cache,target=/outcache,source=outcache source /spack/share/spack/setup-env.sh && \
    ls -ld /outcache && \
    spack env activate alien && \
    spack buildcache create -a -d /outcache

# # Define and compile an arcane environment
# RUN source /spack/share/spack/setup-env.sh && \
#     spack env create arcane --without-view && \
#     spack env activate arcane && \
#     spack add arcane ~wrapper~monoembed && \
#     spack concretize -f && spack install --fail-fast

# # Define and compile an arcane and alien environment
# RUN source /spack/share/spack/setup-env.sh && \
#     spack env create arcane_alien --without-view && \
#     spack env activate arcane_alien && \
#     spack add alien +hypre+petsc+xml+hdf5+move+ref ginkgo=omp trilinos=omp && \
#     spack add arcane ~wrapper~monoembed && \
#     spack concretize -f && spack install --fail-fast

RUN source /spack/share/spack/setup-env.sh && \
    spack clean -a

USER root
RUN rm -rf /tmp/* || true
