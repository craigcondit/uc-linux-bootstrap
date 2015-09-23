#!/bin/bash
set -e

cd "$(dirname $0)"
cd "$(pwd -P)"/uc

set -x
docker build -t insideo/uc:builder --pull - < Dockerfile.builder
docker run --rm=true insideo/uc:builder tar cC /build/root . | xz -z9 > uc.tar.xz
docker build -t insideo/uc .
docker run --rm=true insideo/uc sh -xec 'true'
docker run --rm=true insideo/uc ping -c 1 google.com
