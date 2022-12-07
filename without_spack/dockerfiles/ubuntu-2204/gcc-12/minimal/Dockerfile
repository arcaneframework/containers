# Ubuntu 22.04 minimal dependencies with Arcane.
# Version with GCC 12.

FROM ghcr.io/arcaneframework/ubuntu-2204:gcc-12_clang-14_minimal

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Europe/Paris

RUN cd /tmp \
    && git clone --recurse-submodules https://github.com/arcaneframework/framework \
    && mkdir build \
    && cmake -S /tmp/framework -B /tmp/build -GNinja \
    && cmake --build /tmp/build --target install \
    && cd / && rm -rf /tmp/*
