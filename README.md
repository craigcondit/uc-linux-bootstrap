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
a functional userland with minimal overhead (stage0 is < 5 MB). OpenSSL is present to
allow busybox's wget implementation to download from https sites.

UC Docker supports simple package management using dpkg.

### Future Plans ###

Make self-hosting. Currently we are missing gcc, but that's about it.
