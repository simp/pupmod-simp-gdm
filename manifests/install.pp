# This class installs GDM dependencies.
#
# @param package_list
#   List of required packages to install GDM
#
# @param extra_packages
#   User defined packages to install for GDM
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
# @author Nick Markowski <nmarkowski@keywcorp.com>
#
class gdm::install (
  Array[String] $package_list   = gdm::packages(),
  Array[String] $extra_packages = []
){
  assert_private()

  package { ($package_list + $extra_packages) :
    ensure => 'latest'
  }
}
