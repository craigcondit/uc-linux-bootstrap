#!/bin/bash
set -ex

cd "$(dirname $0)"
cd "$(pwd -P)"/stage0

chmod g+rws ../stage1 ../packages || /bin/true
setfacl -m "default:group::rw" ../stage1 ../packages || /bin/true

time docker build -t insideo/uc-stage0 --pull .
time docker run --rm=true -v "$(pwd)/../stage1":/output:rw insideo/uc-stage0 \
	bash -c "tar cC /build/root . > /output/stage1.tar"
time docker run --rm=true -v "$(pwd)/../stage1":/output:rw insideo/uc-stage0 \
	bash -c "tar cC /chroot/tools . > /output/stage1-tools.tar"
time docker run --rm=true -v "$(pwd)/../packages":/output:rw insideo/uc-stage0 \
	bash -c "tar cC /build/deb . > /output/stage1-packages.tar"

cd ..
echo "stage0 build complete."

