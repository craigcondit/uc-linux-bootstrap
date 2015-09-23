#!/bin/bash
set -ex

cd "$(dirname $0)"
cd "$(pwd -P)"/uc-builder

docker build -t insideo/uc-builder --pull .
docker run --rm=true insideo/uc-builder tar cC /build/root . | xz -z9 > ../uc/uc.tar.xz
docker run --rm=true insideo/uc-builder tar cC /build/deb .> ../packages/bootstrap.tar
cd ../uc
docker build -t insideo/uc .
docker run --rm=true insideo/uc sh -xec 'true'
docker run --rm=true insideo/uc ping -c 1 google.com
set +x
echo "Build complete."
