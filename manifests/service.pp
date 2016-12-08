# Ensures the GDM service is up and running
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
# @author Nick Markowski <nmarkowski@keywcorp.com>
#
class gdm::service {

  # Kick over to runlevel 5 if we're not already there.
  # Uses the runlevel custom fact from the 'simplib' module.
  if $facts['runlevel'] != '5' {
    exec { '/sbin/telinit 5': }
  }

  if ( versioncmp($::gdm_version, '3') < 0 ) and ( versioncmp($::gdm_version, '0.0.0') > 0 ) {
    exec { 'restart_gdm':
      command     => '/usr/bin/killall gdm-binary',
      refreshonly => true,
    }
  }
  # GDM 3+ specific items here
  elsif ( versioncmp($::gdm_version, '3') >= 0 ) {
    service { ['gdm','accounts-daemon']:
      ensure  => 'running',
    }
  }
}
