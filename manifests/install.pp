# This class installs GDM dependencies.
#
# @param package_list List of required packages to install GDM.
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
# @author Nick Markowski <nmarkowski@keywcorp.com>
#
class gdm::install (
  # Default values are in gdm/functions/data.pp
  Array[String] $package_list
){
  assert_private()

  package { $package_list :
    ensure => 'latest'
  }
}
