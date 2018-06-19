# Ensures the GDM service is up and running
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
# @author Nick Markowski <nmarkowski@keywcorp.com>
#
class gdm::service {
  # Don't do anything unless GDM has been detected
  if $facts['gdm_version'] {
    unless 'systemd' in $facts['init_systems'] {
      if $facts['runlevel'] == '5' {
        exec { 'restart_gdm':
          command     => '/usr/bin/killall gdm-binary',
          refreshonly => true
        }
      }
    }

    runlevel { 'graphical': }
  }
}
