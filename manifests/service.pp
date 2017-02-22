# Ensures the GDM service is up and running
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
# @author Nick Markowski <nmarkowski@keywcorp.com>
#
class gdm::service {
  if 'systemd' in $facts['init_systems'] {
    $_services = [
      'gdm',
      'display-manager',
      'accounts-daemon',
      'upower', # replaced hal
      'rtkit-daemon' # used by pulseaudio
    ]
    service { $_services:
      ensure => 'running',
      enable => true
    }
  }
  else {
    unless $facts['runlevel'] == '5' {
      exec { 'gdm telinit 5':
        command     => '/sbin/telinit 5'
      }
    }
    else {
      exec { 'restart_gdm':
        command     => '/usr/bin/killall gdm-binary',
        refreshonly => true
      }
    }
  }
}
