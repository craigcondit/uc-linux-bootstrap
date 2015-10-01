#!/bin/bash
cd "$(dirname $0)"
cd "$(pwd -P)"
cd ..

ARGS=
if [ "$1" == "-f" ]; then
  shift
  ARGS="${ARGS} -f"
fi
if [ "$1" == "--force" ]; then
  shift
  ARGS="${ARGS} -f"
fi
echo "Uploading bootstrap packages..."
find packages -type f -name "*-bootstrap_*.deb" \
	-exec ./upload-package.py -u insideo -o insideo ${ARGS} \
	-a ~/.bintray/apikey -r uc-linux-bootstrap-buggy -c bootstrap -d buggy "{}" \;

echo "Uploading main packages..."
find packages -type f -name "*.deb" -not -name "*-bootstrap_*.deb" \
	-exec ./upload-package.py -u insideo -o insideo ${ARGS} \
	-a ~/.bintray/apikey -r uc-linux-base-buggy -c main -d buggy "{}" \;

