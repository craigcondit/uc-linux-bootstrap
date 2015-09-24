#!/bin/bash
set -ex

cd "$(dirname $0)"
cd "$(pwd -P)"/uc-stage0-builder

docker build -t insideo/uc-stage0-builder --pull .
docker run --rm=true insideo/uc-stage0-builder tar cC /build/root . | xz -z9 > ../uc-stage0/uc-stage0.tar.xz
docker run --rm=true insideo/uc-stage0-builder tar cC /build/deb .> ../packages/stage0-packages.tar
cd ../uc-stage0
docker build -t insideo/uc-stage0 .
docker run --rm=true insideo/uc-stage0 sh -xec 'true'
set +x
echo "Build complete."
