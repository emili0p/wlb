#!/bin/env bash

#este script instala uz doom en arch linux
# 6 de julio de 2026
# fuente https://github.com/UZDoom/UZDoom/wiki/Compilation#linux

# dependencias

sudo pacman -S \
  base-devel \
  git \
  cmake \
  ninja

sudo pacman -S \
  bzip2 \
  openmp \
  openal \
  sdl2-compat \
  libvpx \
  libwebp \
  waylandpp

# pullear el repo
git clone https://github.com/UZDoom/UZDoom.git

mkdir -p UZDoom/build

cd UZDoom/build

# instrucciones cmake
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -G Ninja \
  ..

# buildear
cmake --build .
