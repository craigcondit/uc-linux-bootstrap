#!/bin/bash
set -e

cd "$(dirname $0)"
cd "$(pwd -P)"/uc

set -x
docker build -t ccondit/uc:builder --pull - < Dockerfile.builder
docker run --rm=true ccondit/uc:builder tar cC /build/root . | xz -z9 > uc.tar.xz
docker build -t ccondit/uc .
docker run --rm=true ccondit/uc sh -xec 'true'
docker run --rm=true ccondit/uc ping -c 1 google.com
