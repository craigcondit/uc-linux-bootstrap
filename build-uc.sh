#!/bin/bash
set -e

cd "$(dirname $0)"
cd "$(pwd -P)"/uc

set -x
docker build -t ccondit/uc:builder --pull - < Dockerfile.builder
docker run --rm ccondit/uc:builder tar cC /build/root . | xz -z9 > ../uc.tar.xz

