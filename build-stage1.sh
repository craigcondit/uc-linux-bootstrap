#!/bin/bash
set -ex

cd "$(dirname $0)"
cd "$(pwd -P)"/stage1

chmod g+rws ../stage2 ../packages-stage1 || /bin/true
setfacl -m "default:group::rw" ../stage2 ../packages-stage1 || /bin/true

time docker build -t insideo/uc-stage1 --pull .

if [ "$1" == "fast" ]; then
  echo "Fast stage1 build complete."
  exit 0
fi

time docker run --rm=true -v "$(pwd)/../stage2":/output:rw insideo/uc-stage1 \
        bash -c "tar cC /stage2 . > /output/stage2.tar"
time docker run --rm=true -v "$(pwd)/../packages-stage1":/output:rw insideo/uc-stage1 \
        bash -c "tar cC /packages . > /output/stage2-packages.tar"

cd ../stage2
rm -f stage2.tar.xz || /bin/true
xz -9 stage2.tar

cd ../packages-stage1
find -type f -name "*.deb" -delete
tar xf stage2-packages.tar
rm -f stage2-packages.tar

echo "stage1 build complete."
