# == Class gdm::service
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
# * Nick Markowski <nmarkowski@keywcorp.com>
#
class gdm::service {

  # Kick over to runlevel 5 if we're not already there.
  # Uses the runlevel custom fact from the 'common' module.
  if $::runlevel != '5' {
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
