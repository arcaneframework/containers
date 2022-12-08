#!/bin/bash

CMAKE_GCC='-DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ '
CMAKE_CLANG='-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ '

CMAKE_RELEASE='-DCMAKE_BUILD_TYPE=Release -DARCCORE_BUILD_MODE=Release -DARCANE_BUILD_TYPE=Release '
CMAKE_CHECK='-DCMAKE_BUILD_TYPE=Release -DARCCORE_BUILD_MODE=Check -DARCANE_BUILD_TYPE=Check '
CMAKE_DEBUG='-DCMAKE_BUILD_TYPE=Debug -DARCCORE_BUILD_MODE=Debug -DARCANE_BUILD_TYPE=Debug '

CMAKE_FULL='-DPTScotch_INCLUDE_DIR="/usr/include/scotch" '
CMAKE_MINIMAL=''

OS='ubuntu-2204'
COMPILER='gcc'
DEPS='full'
TYPE='release'

IMAGE_BASE='ubuntu-2204:gcc-12_clang-14_full'


while getopts os:c:d:t: flag
do
    case "${flag}" in
        os) OS=${OPTARG};;
        c) COMPILER=${OPTARG};;
        d) DEPS=${OPTARG};;
        t) TYPE=${OPTARG};;
    esac
done

if [ $OS = 'ubuntu-2204' ]
then
  if [ $COMPILER = 'gcc' ]
  then
    COMPILER='gcc-12_clang-14'
  fi
fi