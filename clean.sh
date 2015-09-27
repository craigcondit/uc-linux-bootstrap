#!/bin/sh

cd "$(dirname $0)"
cd "$(pwd -P)"

rm -f stage1/*.tar stage1/*.tar.gz packages/*.tar
