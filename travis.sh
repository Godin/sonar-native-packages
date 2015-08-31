#!/bin/bash

set -euo pipefail

function fetch {
  local VER=$1
  wget -c -P downloads http://downloads.sonarsource.com/sonarqube/sonarqube-${VER}.zip
  shasum -c - << EOF
$(wget -q -O - http://downloads.sonarsource.com/sonarqube/sonarqube-${VER}.zip.sha)  downloads/sonarqube-${VER}.zip
EOF
}

function build {
  local VER=$1

  echo
  echo "Building packages for SonarQube ${VER}"
  echo

  fetch ${VER}

  cp downloads/sonarqube-${VER}.zip rpm/SOURCES/
  cd rpm
  ./build.sh ${VER}
  cd ..

  cp downloads/sonarqube-${VER}.zip deb/
  cd deb
  ./build.sh ${VER}
  cd ..
}

# LTS
build 4.5.5

# Latest
#build 5.1.2
