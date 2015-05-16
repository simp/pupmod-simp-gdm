# == Class: xwindows
#
# This class sets up xwindows.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class xwindows {
  if ( versioncmp($::operatingsystemmajrelease, '6') > 0 ) {
    $x_package_list = [
      'xorg-x11-drivers',
      'xorg-x11-xinit',
      'xorg-x11-utils',
      'xorg-x11-docs',
    ]

    $additional_packages = [
      'dejavu-sans-fonts',
      'dejavu-sans-mono-fonts',
      'dejavu-serif-fonts',
      'bitmap-fixed-fonts',
      'bitmap-lucida-typewriter-fonts',
      'liberation-mono-fonts',
      'liberation-sans-fonts',
      'liberation-serif-fonts'
    ]
  } else {
    file { '/etc/skel/.xserverrc':
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => 'exec /usr/bin/Xorg -audit 4 -s 15 -auth $HOME/.Xauthorization &'
    }

    $x_package_list = [
      'xorg-x11-apps',
      'xorg-x11-drivers',
      'xorg-x11-xinit',
      'xorg-x11-twm',
      'xterm'
    ]

    $additional_packages = [
      'dejavu-lgc-sans-fonts',
      'dejavu-lgc-sans-mono-fonts',
      'dejavu-lgc-serif-fonts',
      'dejavu-sans-fonts',
      'dejavu-sans-mono-fonts',
      'dejavu-serif-fonts',
      'bitmap-console-fonts',
      'bitmap-fangsongti-fonts',
      'bitmap-fixed-fonts',
      'bitmap-fonts-compat',
      'bitmap-lucida-typewriter-fonts',
      'bitmap-miscfixed-fonts',
      'liberation-mono-fonts',
      'liberation-sans-fonts',
      'liberation-serif-fonts'
    ]
  }

  # Basic XOrg Stuff
  package { $x_package_list :
    ensure => 'latest',
  }

  # Fonts
  package {
    [
      'xorg-x11-fonts-100dpi',
      'xorg-x11-fonts-75dpi',
      'xorg-x11-fonts-ISO8859-1-100dpi',
      'xorg-x11-fonts-ISO8859-1-75dpi',
      'xorg-x11-fonts-Type1',
      'xorg-x11-fonts-misc',
      'xorg-x11-server-Xorg'
    ]:
    ensure => 'latest',
  }

  package { $additional_packages :
    ensure => 'latest'
  }

  # Kick over to runlevel 5 if we're not already there.
  # Uses the runlevel custom fact from the 'common' module.
  if $::runlevel != '5' {
    exec { '/sbin/telinit 5': }
  }
}
