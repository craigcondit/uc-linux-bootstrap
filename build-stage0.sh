#!/bin/bash
set -ex

cd "$(dirname $0)"
cd "$(pwd -P)"/stage0

chmod g+rws ../stage1 ../packages || /bin/true
setfacl -m "default:group::rw" ../stage1 ../packages || /bin/true

time docker build -t insideo/uc-stage0 --pull .

if [ "$1" == "fast" ]; then
  echo "Fast stage0 build complete."
  exit 0
fi

time docker run --rm=true -v "$(pwd)/../stage1":/output:rw insideo/uc-stage0 \
	bash -c "tar cC /build/root . | xz -1 > /output/stage1.tar.xz"
time docker run --rm=true -v "$(pwd)/../stage1":/output:rw insideo/uc-stage0 \
	bash -c "tar cC /chroot/tools . | xz -1 > /output/stage1-tools.tar.xz"
time docker run --rm=true -v "$(pwd)/../stage1":/output:rw insideo/uc-stage0 \
	bash -c "tar cC /build/deb . > /output/stage1-packages.tar"

cd ..
echo "stage0 build complete."

