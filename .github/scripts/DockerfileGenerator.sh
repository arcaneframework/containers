#!/bin/bash

# -*- tab-width: 2; indent-tabs-mode: nil; coding: utf-8-without-signature -*-
# -----------------------------------------------------------------------------
# Copyright 2000-2022 CEA (www.cea.fr) IFPEN (www.ifpenergiesnouvelles.com)
# See the top-level COPYRIGHT file for details.
# SPDX-License-Identifier: Apache-2.0
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# DockerfileGenerator.sh                                          (C) 2000-2022
#
# Script permettant de générer un Dockerfile décrivant une image Docker
# avec Arcane d'installé.
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# v1.3

# Valeurs par défaut.
OS=''
COMPILER=''
COMPILER_NAME=''
COMPILER_VERSION=''
COMPILER_VERSION_WITH_DASH=''
IMAGE_VERSION=''
BUILD_TYPE=''
BASE_IMAGE_DATE=''
DFIN=''
DFOUT=''

C_COMPILER=''
CXX_COMPILER=''
CMAKE_BUILD_TYPE=''
ARCCORE_BUILD_MODE=''
ARCANE_BUILD_TYPE=''
CMAKE_CONFIG=''


# Fonction permettant d'afficher l'aide.
f_help() {
  echo "This script can generate a Dockerfile including Arcane installation from a Docker base image."
  echo "The list of base images can be found here: https://github.com/arcaneframework/framework-ci"
  echo "Warning: There is no automatic check if the base image exists or not."
  echo ""
  echo "Usage: $(basename $0) [OPTIONS]"
  echo "  -h, --help                display this help"
  echo "  -s, --os                  choose the operating system of the base image"
  echo "                            (ex: -s ubuntu-2204)"
  echo "  -c, --compiler            choose the compiler to compile Arcane (gcc/clang/cuda) ('name-version' OR just 'name')"
  echo "                            (ex: -c gcc-12) (ex: -c gcc)"
  echo "  -v, --compiler_version    choose the compiler version (optionnal, if just 'name' in --compiler option)"
  echo "                            (ex: -c gcc -v 12)"
  echo "  -b, --image_version       choose the version of the base image (full/minimal/doc)"
  echo "                            (ex: -b full)"
  echo "  -a, --build_type          choose the Arcane build type (debug/check/release)"
  echo "                            (ex: -a debug)"
  echo "  -d, --base_image_date     choose the date of the base image (default: latest)"
  echo "                            (ex: -d 20221230)"
  echo "  -i, --dockerfile_in       location of the Dockerfile.in (same folder by default)"
  echo "                            (ex: -i \"./df/Dockerfile.in\")"
  echo "  -o, --dockerfile_out      location for the result Dockerfile (same folder by default)"
  echo "                            (ex: -i \"./df/Dockerfile\")"
  echo ""
  echo "Notes:"
  echo " - To choose a compiler, you can use the '-c' option OR the '-c' and '-v' options."
  echo " - You can use only the '-c' option if you want the latest version of the compiler."
  echo " - If you choose 'cuda' in the compiler option, only '.cu' files will be compiled with 'nvcc'."
  echo "   Other C/C++ files will be compiled with the gcc/g++ compiler available in base image."
  echo ""
  echo "This script needs a Dockerfile.in file."
}

# S'il n'y a pas d'options dans l'appel au script.
if [ $# -eq 0 ]
then
  f_help
  exit 0
fi

# On regarde les options données.
while [ $# -gt 0 ]
do
  case "$1" in
    -h | --help)
      f_help
      exit 0
      ;;
    -s | --os)
      OS="$2"
      shift
      ;;
    -c | --compiler)
      COMPILER="$2"
      shift
      ;;
    -v | --compiler_version)
      COMPILER_VERSION="$2"
      shift
      ;;
    -b | --image_version)
      IMAGE_VERSION="$2"
      shift
      ;;
    -a | --build_type)
      BUILD_TYPE="$2"
      shift
      ;;
    -d | --base_image_date)
      BASE_IMAGE_DATE="$2"
      shift
      ;;
    -i | --dockerfile_in)
      DFIN="$2"
      shift
      ;;
    -o | --dockerfile_out)
      DFOUT="$2"
      shift
      ;;
    *)
      echo "Unknown parameter: $1"
      f_help
      exit 1
      ;;
  esac
  shift
done


# On traite le cas où on utilise l'option '-c'.
# S'il n'y a pas de tiret dans le nom du compilateur,
# c'est que l'utilisateur n'a pas donné de version
# (ou alors il a donné une version avec l'option -v).
if [[ ! "$COMPILER" =~ .*-.* ]]
then
  COMPILER_NAME=$COMPILER

# Si l'utilisateur a entré l'option '-c' avec une version, on remplit
# les variables $COMPILER_NAME et $COMPILER_VERSION en splitant
# l'entrée utilisateur en deux.
elif [ -n "$COMPILER" ]
then
  COMPILER_NAME=$(echo "$COMPILER" | cut -d "-" -f 1)
  COMPILER_VERSION=$(echo "$COMPILER" | cut -d "-" -f 2)
fi


# Si l'utilisateur n'a pas donné de version, on ne doit
# pas mettre de tiret dans les noms (voir Dockerfile.in).
if [ -n "$COMPILER_VERSION" ]
then
  COMPILER_VERSION_WITH_DASH="-$COMPILER_VERSION"
fi


# Si l'utilisateur n'a pas spécifié d'emplacement pour le
# Dockerfile.in, on le recherche dans le répertoire courant.
if [ -z "$DFIN" ]
then
  DFIN='./Dockerfile.in'
fi


# Si l'utilisateur n'a pas spécifié d'emplacement pour le
# Dockerfile, on le place dans le répertoire courant.
if [ -z "$DFOUT" ]
then
  DFOUT='./Dockerfile'
fi


# Si l'utilisateur n'a pas spécifié de date, on met 'latest'.
if [ -z "$BASE_IMAGE_DATE" ]
then
  BASE_IMAGE_DATE='latest'
fi


# On a besoin du nom de l'OS de l'image de base (voir framework-ci).
if [ -z "$OS" ]
then
  echo "Operating system of the base image needed."
  f_help
  exit 1
fi


# On a besoin du compilateur de l'image de base (voir framework-ci).
if [ -z "$COMPILER_NAME" ]
then
  echo "Compiler name needed."
  f_help
  exit 1

elif [ "$COMPILER_NAME" = 'gcc' ]
then
  C_COMPILER='gcc'
  CXX_COMPILER='g++'

elif [ "$COMPILER_NAME" = 'clang' ]
then
  C_COMPILER='clang'
  CXX_COMPILER='clang++'

elif [ "$COMPILER_NAME" = 'cuda' ]
then
  C_COMPILER='gcc'
  CXX_COMPILER='g++'
  CMAKE_CONFIG+='-D ARCANE_ACCELERATOR_MODE=CUDANVCC -D CMAKE_CUDA_COMPILER=nvcc '

else
  echo "Unknown compiler: $COMPILER_NAME"
  f_help
  exit 1
fi


# On a besoin du type de build Arcane désiré.
if [ -z "$BUILD_TYPE" ]
then
  echo "Arcane build type needed."
  f_help
  exit 1

elif [ "$BUILD_TYPE" = 'release' ]
then
  CMAKE_BUILD_TYPE='Release'
  ARCCORE_BUILD_MODE='Release'
  ARCANE_BUILD_TYPE='Release'
  
elif [ "$BUILD_TYPE" = 'debug' ]
then
  CMAKE_BUILD_TYPE='Debug'
  ARCCORE_BUILD_MODE='Debug'
  ARCANE_BUILD_TYPE='Debug'

elif [ "$BUILD_TYPE" = 'check' ]
then
  CMAKE_BUILD_TYPE='Release'
  ARCCORE_BUILD_MODE='Check'
  ARCANE_BUILD_TYPE='Check'

else
  echo "Unknown type: $BUILD_TYPE"
  f_help
  exit 1
fi


# On a besoin de savoir la taille de l'image de base (voir framework-ci).
if [ -z "$IMAGE_VERSION" ]
then
  echo "Image version needed."
  f_help
  exit 1

elif [ "$IMAGE_VERSION" = 'full' ]
then
  CMAKE_CONFIG+='-D PTScotch_INCLUDE_DIR="/usr/include/scotch" '

elif [ "$IMAGE_VERSION" = 'minimal' ] || [ "$IMAGE_VERSION" = 'doc' ]
then
  CMAKE_CONFIG+=''

else
  echo "Unknown image version: $IMAGE_VERSION"
  f_help
  exit 1
fi


# On affiche les caractéristiques du Dockerfile généré.
echo "Dockerfile description:"
echo ""
echo "OS=                 $OS"
echo "COMPILER_NAME=      $COMPILER_NAME"
echo "COMPILER_VERSION=   $COMPILER_VERSION"
echo "IMAGE_VERSION=      $IMAGE_VERSION"
echo "BUILD_TYPE=         $BUILD_TYPE"
echo "BASE_IMAGE_DATE=    $BASE_IMAGE_DATE"
echo ""
echo "C_COMPILER=         $C_COMPILER"
echo "CXX_COMPILER=       $CXX_COMPILER"
if [ "$COMPILER_NAME" = 'cuda' ]
then
  echo "CUDA_COMPILER=      nvcc"
fi
echo "CMAKE_BUILD_TYPE=   $CMAKE_BUILD_TYPE"
echo "ARCCORE_BUILD_MODE= $ARCCORE_BUILD_MODE"
echo "ARCANE_BUILD_TYPE=  $ARCANE_BUILD_TYPE"
echo "CMAKE_CONFIG=       $CMAKE_CONFIG"
echo ""
echo "IMAGE_BASE=         $OS"":""$COMPILER_NAME$COMPILER_VERSION_WITH_DASH""_""$IMAGE_VERSION""_latest"
echo "DOCKERFILE.IN=      $DFIN"
echo "DOCKERFILE=         $DFOUT"
echo ""
echo "IMAGE_OUT=          arcane_"$OS":"$COMPILER_NAME$COMPILER_VERSION_WITH_DASH"_"$IMAGE_VERSION"_"$BUILD_TYPE"_"$BASE_IMAGE_DATE


if sed "\
s:@OS@:$OS:g; \
s:@COMPILER_NAME@:$COMPILER_NAME:g; \
s:@COMPILER_VERSION@:$COMPILER_VERSION:g; \
s:@COMPILER_VERSION_WITH_DASH@:$COMPILER_VERSION_WITH_DASH:g; \
s:@IMAGE_VERSION@:$IMAGE_VERSION:g; \
s:@C_COMPILER@:$C_COMPILER:g; \
s:@CXX_COMPILER@:$CXX_COMPILER:g; \
s:@BUILD_TYPE@:$BUILD_TYPE:g; \
s:@BASE_IMAGE_DATE@:$BASE_IMAGE_DATE:g; \
s:@CMAKE_BUILD_TYPE@:$CMAKE_BUILD_TYPE:g; \
s:@ARCCORE_BUILD_MODE@:$ARCCORE_BUILD_MODE:g; \
s:@ARCANE_BUILD_TYPE@:$ARCANE_BUILD_TYPE:g; \
s:@CMAKE_CONFIG@:$CMAKE_CONFIG:g; \
s*@DATE@*$(date +'%d/%m/%Y at %H:%M:%S')*g; \
" $DFIN > $DFOUT
then
  echo ""
  echo "Dockerfile generated."
else
  echo ""
  echo "Error: Dockerfile not generated."
fi
