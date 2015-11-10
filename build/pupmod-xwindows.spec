Summary: XWindows Puppet Module
Name: pupmod-xwindows
Version: 4.1.0
Release: 4
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: pupmod-auditd >= 4.1.0-3
Requires: pupmod-common >= 4.1.0-5
Requires: pupmod-iptables >= 4.1.0-3
Requires: puppet >= 3.3.0
Requires: puppetlabs-stdlib >= 4.1.0-0
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Requires: pupmod-simplib >= 1.0.0-0
Obsoletes: pupmod-xwindows-test

Prefix:"/etc/puppet/environments/simp/modules"

%description
This Puppet module provides the capability to configure a basic XOrg server as
well as GDM.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/xwindows

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/xwindows
done

mkdir -p %{buildroot}/usr/share/simp/tests/modules/xwindows

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/xwindows

%files
%defattr(0640,root,puppet,0750)
/etc/puppet/environments/simp/modules/xwindows

%post
#!/bin/sh

if [ -d /etc/puppet/environments/simp/modules/xwindows/plugins ]; then
  /bin/mv /etc/puppet/environments/simp/modules/xwindows/plugins /etc/puppet/environments/simp/modules/xwindows/plugins.bak
fi

%postun
# Post uninstall stuff

%changelog
* Mon Nov 09 2015 Chris Tessmer <chris.tessmer@onypoint.com> - 4.1.0-4
- migration to simplib and simpcat (lib/ only)

* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-3
- Changed puppet-server requirement to puppet

* Tue Sep 30 2014 Nick Markowski <nmarkowski@keywcorp.com> - 4.1.0-2
- Updating for RHEL7

* Mon May 05 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-1
- Removed the fix-etc-gconf exec since it is no longer required.

* Wed Mar 19 2014 Nick Markowski <nmarkowski@keywcorp.com> - 4.1.0-0
- Refactored module for puppet3/hiera, and added spec tests.
- gdm::conf was deprecated and has been removed.  All gdm config
  is set by gdm::set.

* Tue Oct 08 2013 Kendall Moore <kmoore@keywcorp.com> - 4.0.0-7
- Updated all erb templates to properly scope variables.

* Wed Oct 02 2013 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-6
- Use 'versioncmp' for all version comparisons.

* Tue Dec 11 2012 Maintenance
4.0.0-5
- Created a Cucumber test to install xwindows from the xwindows module and ensure that
  all dependecnies were properly installed with it.
- Created a Cucumber test to ensure that the system runlevel changes to 5 and installing
  xwindows.

* Fri May 25 2012 Maintenance
4.0.0-4
- Now use augeas to manage /etc/gdm/custom.conf
- Added a xwindows::gdm::sec class that applies common security settings using
  the gconf type.
- Created a new native type for manipulating gconf settings via gconftool-2.
- Moved mit-tests to /usr/share/simp...
- Updated pp files to better meet Puppet's recommended style guide.

* Fri Mar 02 2012 Maintenance
4.0.0-3
- Improved test stubs.

* Mon Dec 26 2011 Maintenance
4.0.0-2
- Updated the spec file to not require a separate file list.
- Scoped all of the top level variables.

* Mon Dec 05 2011 Maintenance
4.0.0-1
- Fixed the restart for GDM to work with RHEL6.
- Started work on the new custom.conf file for RHEL6 but it still needs work.

* Wed Nov 02 2011 Maintenance
4.0.0-0
- Updated to handle RHEL6

* Mon Oct 10 2011 Maintenance
2.0.0-3
- Updated to put quotes around everything that need it in a comparison
  statement so that puppet > 2.5 doesn't explode with an undef error.

* Wed Jun 08 2011 Maintenance - 2.0.0-2
- Now install all packages before attempting to switch to runlevel 5. This
  fixes the problem where X wouldn't start until the next puppet run (if at
  all).
- Updated documentation reference comment.
- Now spawn X with -audit 4 and -s 15 by default.

* Fri Feb 04 2011 Maintenance - 2.0.0-1
- Changed all instances of defined(Class['foo']) to defined('foo') per the
  directions from the Puppet mailing list.

* Tue Jan 11 2011 Maintenance
2.0.0-0
- Refactored for SIMP-2.0.0-alpha release

* Tue Oct 26 2010 Maintenance - 1-1
- Converting all spec files to check for directories prior to copy.

* Mon May 24 2010 Maintenance
1.0-0
- Code refactor.

* Thu Oct 08 2009 Maintenance
0.1-5
- Added a patch for checking the permissions on the GDM directory since having a
  strict root umask appears to mess things up.

* Fri Oct 2 2009 Maintenance
0.1-4
- Fixed the gdm ordering issues.  GDM will now install properly and the conf
  file will get placed appropriately.

* Thu Oct 1 2009 Maintenance
0.1-3
- Fixed the GDM template
- Set DESKTOP="GNOME" in /etc/sysconfig/desktop

* Tue Sep 29 2009 Maintenance
0.1-0
- Initial configuration module
