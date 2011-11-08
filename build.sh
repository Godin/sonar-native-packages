#!/bin/sh

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

./build-rpm.sh $1
./build-deb.sh $1
