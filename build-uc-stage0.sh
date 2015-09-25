#!/bin/bash
set -ex

cd "$(dirname $0)"
cd "$(pwd -P)"/uc-stage0-builder

chmod g+rws ../uc-stage0 ../packages || /bin/true
setfacl -m "default:group::rw" ../uc-stage0 ../packages || /bin/true

docker build -t insideo/uc-stage0-builder --pull .
docker run --rm=true -v "$(pwd)/../uc-stage0":/output:rw insideo/uc-stage0-builder \
	bash -c "tar cC /build/root . | gzip > /output/uc-stage0.tar.gz"

docker run --rm=true -v "$(pwd)/../packages":/output:rw insideo/uc-stage0-builder \
	bash -c "tar cC /build/deb .> /output/stage0-packages.tar"

cd ../uc-stage0
docker build -t insideo/uc-stage0 .
docker run --rm=true insideo/uc-stage0 sh -xec 'true'
set +x
echo "Build complete."
