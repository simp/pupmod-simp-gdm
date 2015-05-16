# == Class: xwindows::gdm
#
# This class installs gdm and sets up the DESKTOP environment variable and
# /etc/gconf.
#
# == Parameters
#
# [*include_sec*]
#   Whether or not to include the bult in 'sec' class.  Defaults to true.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class xwindows::gdm(
  $include_sec = true
) inherits xwindows {

  if $include_sec {
    include 'xwindows::gdm::sec'
  }

  # GNOME Display Manager
  package { 'gdm': ensure => 'latest' }

  if ( versioncmp($::gdm_version, '3') < 0 ) and ( versioncmp($::gdm_version, '0.0.0') > 0 ) {
    # Set the desktop variable
    file { '/etc/sysconfig/desktop':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "DESKTOP='GNOME'\n"
    }

    # Audit the default gdm system-wide configuration file.
    if defined('auditd') and defined(Class['auditd']) {
      auditd::add_rules { 'system_gdm':
        content => '-w /usr/share/gdm/defaults.conf -p wa -k CFG_sys'
      }
    }

    exec { 'restart_gdm':
      command     => '/usr/bin/killall gdm-binary',
      refreshonly => true,
      require => Package['gdm']
    }
  }
  # GDM 3+ specific items here
  elsif ( versioncmp($::gdm_version, '3') >= 0 ) {
    service { ['gdm','accounts-daemon']:
      ensure => 'running',
      require => Package['gdm']
    }
  }

  validate_bool($include_sec)
}
