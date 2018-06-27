# This class configures, installs, and ensures GDM is running.
#
# @param dconf_hash
#   ``dconf`` settings applicable to GDM
#
#  @see dconf(5)
#  @see data/common.yaml
#
# @param packages
#   A Hash of packages to be installed
#
#   * NOTE: Setting this will *override* the default package list
#   * The ensure value can be set in the hash of each package, like the example
#     below:
#
#   @example Override packages
#     { 'gdm' => { 'ensure' => '1.2.3' } }
#
#   @see data/common.yaml
#
# @param package_ensure
#   The SIMP global catalyst to set the default `ensure` settings for packages
#   managed with this module.
#
# @param include_sec Boolean
#   This no longer has any effect
#
# @param auditd
#   Enable auditd support for this module via the ``simp-auditd`` module
#
# @author https://github.com/simp/pupmod-simp-gdm/graphs/contributors
#
class gdm (
  Hash[String, Dconf::SettingsHash] $dconf_hash,
  Hash[String[1], Optional[Hash]]   $packages,
  Hash                              $settings,
  Simplib::PackageEnsure            $package_ensure = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
  Boolean                           $include_sec    = true,
  Boolean                           $auditd         = simplib::lookup('simp_options::auditd', { 'default_value' => false }),
) {

  simplib::assert_metadata($module_name)

  include gdm::install
  include gdm::service

  Class['gdm::install'] ~> Class['gdm::service']

  # If GDM isn't installed, this won't actually exist so we need a two pass run
  # to get this right
  if $facts['gdm_version'] {
    if ( versioncmp($facts['gdm_version'], '3') < 0 ) and ( versioncmp($facts['gdm_version'], '0.0.0') > 0 ) {
      # Set the desktop variable
      file { '/etc/sysconfig/desktop':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "DESKTOP='GNOME'\n",
        notify  => Class['gdm::service']
      }

      # Audit the default gdm system-wide configuration file.
      if $auditd {
        auditd::rule { 'system_gdm':
          content => '-w /usr/share/gdm/defaults.conf -p wa -k CFG_sys'
        }
      }
    }
    else {
      include 'gdm::config'

      Class['gdm::install'] -> Class['gdm::config']
      Class['gdm::config'] ~> Class['gdm::service']
    }
  }
  else {
    notify { "Additional Puppet Run Needed for ${module_name}": }
  }
}
