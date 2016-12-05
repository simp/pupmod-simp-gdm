# This class installs GDM dependencies.
#
# @param package_list Array
# List of required packages to install GDM.
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
# @author Nick Markowski <nmarkowski@keywcorp.com>
#
class gdm::install (
  # Default values are in gdm/functions/data.pp
  $package_list
){
  assert_private()

  package { $package_list :
    ensure => 'latest'
  }
}
