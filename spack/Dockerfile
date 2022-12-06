ARG BASEIMAGE=ecpe4s/rhel8-runner-x86_64

FROM $BASEIMAGE

ARG SPACK_VERSION=0.19.0
ARG RECIPES_BRANCH=main

ARG UID=1000
ARG GID=100

RUN ( ( getent group $GID ) ||  groupadd --gid $GID user ) \
    &&( ( getent passwd $UID ) || useradd --gid $GID --uid $UID user )

RUN mkdir -p /spack /recipes /home/user && useradd spack && chown -R user: /spack /recipes /home/user

ADD install_spack_deps.sh /tmp/

RUN bash /tmp/install_spack_deps.sh

USER user

SHELL ["/bin/bash", "-c"]

# Download last release of spack
RUN curl -L https://github.com/spack/spack/releases/download/v${SPACK_VERSION}/spack-${SPACK_VERSION}.tar.gz | tar xz -C /spack --strip-components=1 && \
    source /spack/share/spack/setup-env.sh && \
    spack config --scope site add 'packages:all:target:[x86_64]' && \
    spack compiler find

# Get arcane recipes
RUN curl -L https://github.com/arcaneframework/spack_recipes/archive/refs/heads/${RECIPES_BRANCH}.tar.gz | tar xz -C /recipes --strip-components 1

# setup our recipes
RUN source /spack/share/spack/setup-env.sh && \
    spack repo add --scope site /recipes

# Define and compile an alien environment
RUN source /spack/share/spack/setup-env.sh && \
    spack env create alien --without-view && \
    spack env activate alien && \
    spack add alien +hypre+petsc+xml+hdf5+move+ref ginkgo=omp trilinos=omp && \
    spack concretize -f && spack install --fail-fast

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

RUN rm -rf /tmp/* || true
