# == Class: gdm
#
# This class configures, installs, and ensures GDM is running.
#
# == Parameters
#
# [*include_sec*]
# Boolean
# Whether or not to include gdm::sec
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
# * Nick Markowski <nmarkowski@keywcorp.com>
#
class gdm (
  # Default values are in gdm/functions/data.pp
  $include_sec
) {
  validate_bool($include_sec)

  include '::gdm::install'
  include '::gdm::service'
  if $include_sec {
    include '::gdm::sec'
  }

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
  }

  Class['gdm::install'] ->
  Class['gdm::service'] ->
  Class['gdm']
}
