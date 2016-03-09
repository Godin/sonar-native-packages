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

# prepare fresh directories
rm -rv tmp/
mkdir -p tmp/DEBIAN/

# changelog
DATE=`date -R`

echo "sonar (${VER}) unstable; urgency=low

  * See http://www.sonarsource.org/downloads for more details.

 -- Evgeny Mandrikov <mandrikov@gmail.com>  ${DATE}
" > debian/changelog

# prepare sonar
unzip sonarqube-${VER}.zip -d tmp/opt/
mv tmp/opt/sonarqube-${VER}/ tmp/opt/sonar/

# Remove unnecessary files
rm -rv tmp/opt/sonar/bin/windows*
# Removed from official distribution in 5.4:
rm -rv tmp/opt/sonar/bin/solaris* || true
rm -rv tmp/opt/sonar/bin/macosx*
# Removed from official distribution in 5.1:
rm -rv tmp/opt/sonar/bin/linux-ppc* || true

# Fix EOL in configuration files
for i in tmp/opt/sonar/conf/* ; do
  echo "dos2unix $i"
  awk '{ sub("\r$", ""); print }' $i > $i.new
  mv $i.new $i
done

# lintian overrides
mkdir -p tmp/usr/share/lintian/overrides/
cp -T debian/sonar.lintian-overrides tmp/usr/share/lintian/overrides/sonar

# license
mkdir -p tmp/usr/share/doc/sonar/
cp debian/copyright tmp/usr/share/doc/sonar/

# conffiles
cp -T debian/conffiles tmp/DEBIAN/conffiles

# init.d
mkdir -p tmp/etc/init.d/
cp -T debian/sonar.init tmp/etc/init.d/sonar
chmod 755 tmp/etc/init.d/sonar

# postinst and postrm
cp -T debian/sonar.postinst tmp/DEBIAN/postinst
chmod 755 tmp/DEBIAN/postinst
cp -T debian/sonar.postrm tmp/DEBIAN/postrm
chmod 755 tmp/DEBIAN/postrm

dpkg-gencontrol -Ptmp

fakeroot dpkg-deb -b tmp sonar.deb
