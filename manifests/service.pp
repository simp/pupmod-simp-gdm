# @summary Ensures the GDM service is properly configured
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
# @author https://github.com/simp/pupmod-simp-acpid/graphs/contributors
#
class gdm::service (
  Optional[Array[String[1]]] $services = undef
){
  Service { 'gdm':
    ensure => 'running',
    enable => 'true'
  }

  if $services and simplib::module_exist('svckill') {
    svckill::ignore { $services: }
  }
}
