#!/bin/sh
set -e

usage() {
  echo "Usage: $0 <package> <distro>" >&2
  exit 1
}

PKG=$1
[ ! -z $PKG ] || usage

DISTRO=$2
[ ! -z $DISTRO ] || usage

export BINTRAY_USERNAME=insideo
export BINTRAY_ORGANIZATION=insideo
export BINTRAY_API_KEY=$(cat ~/.bintray/apikey)

NAME=$(dpkg-deb -f "${PKG}" Package)
VERSION=$(dpkg-deb -f "${PKG}" Version)
ARCH=$(dpkg-deb -f "${PKG}" Architecture)
[ ! -z "$ARCH" ] || ARCH=amd64

# TODO encompass the calling script
~/code/bintray-upload/bintray_upload.py \
	--no-confirm \
	--repo uc-linux-pkgs \
	--name "${NAME}" \
	--version "${VERSION}" \
	--architecture "${ARCH}" \
	--component "${DISTRO}" \
	--distribution "${DISTRO}" "${PKG}" || echo "Warning: Unable to update ${PKG}" >&2

exit 0
