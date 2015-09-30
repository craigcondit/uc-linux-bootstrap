#!/bin/bash
set -ex

cd "$(dirname $0)"
cd "$(pwd -P)"/stage2

#chmod g+rws ../stage3 ../packages || /bin/true
#setfacl -m "default:group::rw" ../stage3 ../packages || /bin/true

time docker build -t insideo/uc-stage2 --pull .

if [ "$1" == "fast" ]; then
  echo "Fast stage2 build complete."
  exit 0
fi

#time docker run --rm=true -v "$(pwd)/../stage3":/output:rw insideo/uc-stage2 \
#        bash -c "tar cC /stage3 . > /output/stage3.tar"
#time docker run --rm=true -v "$(pwd)/../stage3":/output:rw insideo/uc-stage2 \
#        bash -c "tar cC /packages . > /output/stage3-packages.tar"
#
#cd ../stage3
#rm -f stage3.tar.xz || /bin/true
#xz -9 stage3.tar
#
#cd ../packages
#tar xf ../stage3/stage3-packages.tar

echo "stage2 build complete."
