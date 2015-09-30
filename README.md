# uc-docker

Micro-container for Docker which is designed to be small (~ 18 MB),
extensible (support for Debian .deb packages), and functional. Further,
images should be able to have reproducible builds.

### Base Packages ###
    - glibc 2.22
    - zlib 1.2.8
    - busybox 1.23.2
    - openssl 1.0.2d

This small base gives us wide compatibility with a large range of existing
software as well as the ability to build and deploy simple .deb packages.

Glibc was chosen due to its widespread support. Busybox was chosen to give
a functional userland with minimal overhead. OpenSSL is present to allow
busybox's wget implementation to download from https sites. UC Docker
supports simple package management using dpkg from busybox.

### Credits ###

Obviously the source packages...

Many of the initial build scripts (and a few patches) were taken from
[Linux From Scratch](http://linuxfromscratch.org/).

### Build Process ###

The UC Linux build process is split into several stages:

#### stage0 ####

To build stage0, execute the following:

    ./build-stage0.sh

Stage 0 starts from a debian:jessie root image and builds several packages
(most of which install to /tools):

    - base-files (core filesystem)
    - binutils
    - linux headers
    - glibc
    - libstdc++
    - gcc
    - busybox
    - make
    - bash
    - gawk
    - sed
    - perl
    - openssl

Busybox and openssl are built at this stage to give us a simple way to download
additional packages from ftp, http, and https servers in stage1.

Once these pacakges are created, the build script populates stage1 with 3
tarballs:

    - stage1.tar.xz
    - stage1-tools.tar.xz
    - stage1-packages.tar

#### stage1 ####

To build stage1, execute the following:

    ./build-stage1.sh

Stage 1 is pre-populated with base-files and /tools from the stage0 container.
At this point, all code compiled has been generated with tools that were not
present in the initial debian:jessie container (which means we are almost
self-hosting).

The purpose of stage1 is to get UC Linux to the point where basic system packages
can be installed, and a build toolchain generated which will allow us to start
with a very basic stage2 image, and install or build packages at will.

The following packages are built in stage1 (bootstrap packages are intented to
be temporary until the system is fully self-hosting):

  - linux 4.2.1
    - linux-devel
  - glibc 2.22
    - libc-bootstrap
    - libc-devel-bootstrap
    - glibc-bin-bootstrap
  - zlib 1.2.8
    - libz-bootstrap
    - libz-devel-bootstrap
  - file 5.25
    - file-bootstrap
    - libmagic-bootstrap
    - libmagic-devel-bootstrap
  - binutils 2.25.1
    - binutils-bootstrap
    - binutils-devel-bootstrap
  - m4 1.4.17
    - m4-bootstrap
  - gmp 6.0.0a
    - libgmp-bootstrap
    - libgmp-devel-bootstrap
  - patch 2.7.5
    - patch-bootstrap
  - mpfr 3.1.3
    - libmpfr-bootstrap
    - libmpfr-devel-bootstrap
  - mpc 1.0.3
    - libmpc-bootstrap
    - libmpc-devel-bootstrap
  - gcc 5.2.0
    - gcc-bootstrap
    - libgcc-bootstrap
    - libstdc++-bootstrap
    - libasan-bootstrap
    - libatomic-bootstrap
    - libcilkrts-bootstrap
    - libgomp-bootstrap
    - libitm-bootstrap
    - liblsan-bootstrap
    - libquadmath-bootstrap
    - libssp-bootstrap
    - libtsan-bootstrap
    - libubsan-bootstrap
    - libvtv-bootstrap
  - busybox 1.23.2
    - busybox-bootstrap
  - openssl 1.0.2d
    - openssl-bootstrap
    - libssl-bootstrap
    - libssl-devel-bootstrap

#### stage2 ####

TODO

### Future Plans ###
Upload all packages to bintray.

