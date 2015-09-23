# uc-docker

Micro-container for [Docker][docker] which is designed to be small (~ 18 MB),
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
a functional userland with minimal overhead (< 1 MB). OpenSSL is present to
allow busybox's wget implementation to download from https sites.

### Future Plans ###

Implement (simple package) support so that images built from this can do
things like:

```
RUN uc-install postgresql-7.5.0-1uc jdk-8u60-1uc
```
