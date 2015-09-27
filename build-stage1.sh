#!/bin/bash
set -ex

cd "$(dirname $0)"
cd "$(pwd -P)"/stage1

time docker build -t insideo/uc-stage1 .
docker run --rm=true insideo/uc-stage1 sh -xec 'true'
set +x
echo "Build complete."
