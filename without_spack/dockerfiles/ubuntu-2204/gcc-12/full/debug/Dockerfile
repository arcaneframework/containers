# Ubuntu 22.04 full dependencies.
# Arcane version Debug compiled with GCC 12.

FROM ghcr.io/arcaneframework/ubuntu-2204:gcc-12_clang-14_full

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Europe/Paris

RUN cd /tmp \
    && git clone --recurse-submodules https://github.com/arcaneframework/framework \
    && mkdir build \
    && cmake \
        -S /tmp/framework \
        -B /tmp/build \
        -G Ninja \
        -D BUILD_SHARED_LIBS=ON \
        -D CMAKE_C_COMPILER=gcc \
        -D CMAKE_CXX_COMPILER=g++ \
        -D ARCCORE_CXX_STANDARD=23 \
        -D PTScotch_INCLUDE_DIR="/usr/include/scotch" \
        -D ARCANE_DEFAULT_PARTITIONER=Metis \
        -D CMAKE_BUILD_TYPE=Debug \
        -D ARCCORE_BUILD_MODE=Debug \
        -D ARCANE_BUILD_TYPE=Debug \
    && cmake --build /tmp/build --target install \
    && cd / && rm -rf /tmp/*

