#!/bin/sh

# Requires:
#   app-arch/dpkg
#   sys-apps/fakeroot

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

VER=$1

echo "Building DEB package"
rm -v deb/*.zip || true
cp /usr/distfiles/sonar-${VER}.zip deb/
cd deb/
./build.sh ${VER}
cd ..

echo "Building DEB repository"
cp -v deb/sonar.deb repo/deb/binary/sonar_${VER}_all.deb
cd repo/deb/
dpkg-scanpackages binary /dev/null | gzip -9c > binary/Packages.gz
cd ../../
