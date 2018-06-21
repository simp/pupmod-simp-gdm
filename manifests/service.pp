# Ensures the GDM service is up and running
#
# @param services
#   A list of services relevant to the proper functioning of GDM
#
#   * These services will *not* be individually managed. Instead, this list
#     will be used for ensuring that the services are not disabled by the
#     `svckill` module if it is present.
#
#   @see data/os/*.yaml
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
# @author Nick Markowski <nmarkowski@keywcorp.com>
#
class gdm::service (
  Optional[Array[String[1]]] $services = undef
){
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

  if $services and simplib::module_exist('svckill') {
    svckill::ignore { $services: }
  }
}
