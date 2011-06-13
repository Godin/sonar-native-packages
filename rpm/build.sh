#!/bin/sh

set -e

if [ -z "$1" ]; then
  echo "Usage: build.sh <version>"
  exit 1
fi

version=$1

pushd $(dirname $0)

# prepare fresh directories
rm -rf BUILD RPMS SRPMS tmp || true
mkdir -p BUILD RPMS SRPMS

# build
rpmbuild -ba --define="_topdir $PWD" --define="_tmppath $PWD/tmp" --define="ver $version" SPECS/sonar.spec
