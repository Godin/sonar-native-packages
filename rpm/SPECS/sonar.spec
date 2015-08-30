# Don't try fancy stuff like debuginfo, which is useless on binary-only
# packages. Don't strip binary too
# Be sure buildpolicy set to do nothing
%define		__spec_install_post %{nil}
%define		debug_package %{nil}
%define		__os_install_post %{_dbpath}/brp-compress

Name:		sonar
Version:	%{ver}
Release:	1
Summary:	Open platform to manage code quality
Vendor:		SonarSource
Packager:	Evgeny Mandrikov <mandrikov@gmail.com>
Group:		Development/Tools
License:	LGPLv3
URL:		http://sonarsource.org/
Source:		sonarqube-%{ver}.zip
Source1:	sonar.init.in
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

#BuildRequires:	
#Requires:	
BuildArch:	noarch
Autoreq:	0
Autoprov:	0

%description
Sonar is an open source software quality management tool, dedicated
to continuously analyze and measure source code quality.

%prep
%setup -q -n sonarqube-%{ver}

%build

%install
rm -rf %{buildroot}

# Remove unnecessary files
rm -rv bin/windows*
rm -rv bin/solaris*
rm -rv bin/macosx*
rm -rv bin/linux-ppc*

# Fix EOL in configuration files
for i in conf/* ; do
  echo "dos2unix $i"
  awk '{ sub("\r$", ""); print }' $i > $i.new
  mv $i.new $i
done

mkdir -p %{buildroot}/opt/sonar/
cp -R %{_builddir}/sonarqube-%{ver}/* %{buildroot}/opt/sonar/

%__install -D -m0755 "%{SOURCE1}" "%{buildroot}/etc/init.d/%{name}"

%pre
/usr/sbin/groupadd -r sonar &>/dev/null || :
/usr/sbin/useradd -g sonar -s /bin/sh -r -d "/opt/sonar" sonar &>/dev/null || :

%post
/sbin/chkconfig --add sonar

%preun
if [ "$1" = 0 ] ; then
  # if this is uninstallation as opposed to upgrade, delete the service
  /sbin/service sonar stop > /dev/null 2>&1
  /sbin/chkconfig --del sonar
fi
exit 0

%clean
rm -rf %{buildroot}

%files
%defattr(0644,sonar,sonar,0755)
/opt/sonar
%config(noreplace) /opt/sonar/conf/sonar.properties

%attr(0755,sonar,sonar) /opt/sonar/bin/linux-x86-32/sonar.sh
%attr(0755,sonar,sonar) /opt/sonar/bin/linux-x86-32/wrapper
%attr(0755,sonar,sonar) /opt/sonar/bin/linux-x86-32/lib/libwrapper.so

%attr(0755,sonar,sonar) /opt/sonar/bin/linux-x86-64/sonar.sh
%attr(0755,sonar,sonar) /opt/sonar/bin/linux-x86-64/wrapper
%attr(0755,sonar,sonar) /opt/sonar/bin/linux-x86-64/lib/libwrapper.so

%attr(0755,root,root) %config /etc/init.d/%{name}
