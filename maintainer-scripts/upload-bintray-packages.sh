#!/bin/bash

BINTRAY_USER=insideo
BINTRAY_ORG=insideo
BINTRAY_API_KEY_FILE=~/.bintray/apikey
DISTRO=helium
MAIN_REPOSITORY=uc-linux-main-helium
BOOTSTRAP_REPOSITORY=uc-linux-bootstrap-helium

usage() {
  echo "Usage: $0 [--force] <stage0,stage1,stage2>" >&2
  exit 1
}

cd "$(dirname $0)"
cd "$(pwd -P)"
cd ..

ARGS=
if [ "$1" == "--force" ]; then
  shift
  ARGS="${ARGS} -f"
fi

STAGE=$1
if [ -z "${STAGE}" ]; then
  usage
fi

echo "Uploading bootstrap packages for ${STAGE}..."
find packages-${STAGE} -type f -name "*-bootstrap_*.deb" \
	-exec ./upload-package.py -u "${BINTRAY_USER}" -o "${BINTRAY_ORG}" ${ARGS} \
	-a "${BINTRAY_API_KEY_FILE}" -r "${BOOTSTRAP_REPOSITORY}" -c bootstrap -d "${DISTRO}" "{}" \;

echo "Uploading main packages for ${STAGE}..."
find packages-${STAGE} -type f -name "*.deb" -not -name "*-bootstrap_*.deb" \
	-exec ./upload-package.py -u "${BINTRAY_USER}" -o "${BINTRAY_ORG}" ${ARGS} \
	-a "${BINTRAY_API_KEY_FILE}" -r "${MAIN_REPOSITORY}" -c main -d "${DISTRO}" "{}" \;
