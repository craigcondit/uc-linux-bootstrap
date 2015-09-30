#!/bin/bash
set -ex

cd "$(dirname $0)"
cd "$(pwd -P)"/stage1

chmod g+rws ../stage2 ../packages || /bin/true
setfacl -m "default:group::rw" ../stage2 ../packages || /bin/true

time docker build -t insideo/uc-stage1 --pull .

if [ "$1" == "fast" ]; then
  echo "Fast stage1 build complete."
  exit 0
fi

time docker run --rm=true -v "$(pwd)/../stage2":/output:rw insideo/uc-stage1 \
        bash -c "tar cC /stage2 . | xz -1 > /output/stage2.tar.xz"
time docker run --rm=true -v "$(pwd)/../stage2":/output:rw insideo/uc-stage1 \
        bash -c "tar cC /packages . > /output/stage2-packages.tar"

cd ../packages
tar xf ../stage2/stage2-packages.jar

echo "stage1 build complete."
