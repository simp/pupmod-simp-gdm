# Ensures the GDM service is properly configured
#
# This will **NOT** switch the runlevel by default since this is a potentially
# dangerous activity if graphics drivers are having issues.
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
  }

  if $services and simplib::module_exist('svckill') {
    svckill::ignore { $services: }
  }
}
