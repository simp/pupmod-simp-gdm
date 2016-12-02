# == Class: gdm::install
#
# This class installs GDM dependencies.
# 
# == Parameters
#
# [*package_list*]
# Array
# List of required packages to install GDM.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
# * Nick Markowski <nmarkowski@keywcorp.com>
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
