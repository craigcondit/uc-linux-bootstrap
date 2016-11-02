#!/bin/bash
set -ex

cd "$(dirname $0)"
cd "$(pwd -P)"/stage3

time docker build -t insideo/uc-stage3 --pull .

echo "stage3 build complete."
