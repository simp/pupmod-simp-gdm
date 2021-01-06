# @summary This class configures, installs, and ensures GDM is running.
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
# @param settings
#   A Hash of settings that will be applied to `/etc/gdm/custom.conf`
#
#   The top-level section keys are well defined but the sub-keys will not be
#   validated
#
#   @example Set [chooser] and [daemon] options
#     {
#       'chooser' => {
#         'Multicast' => 'false'
#       },
#       'daemon' => {
#         'TimedLoginEnable' => 'false'
#         'TimedLoginDelay' => 30
#       }
#     }
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
# @param pam
#   Enable pam support for this module via the ``simp-pam`` module
#
# @param display_mgr_user
#   The name of the local user that runs the display manager.  If pam is enabled
#   this user will be given local access to the system to it can start the service.
#
# @param banner
#   Enable a login screen banner
#
#   * NOTE: any banner settings set via `dconf_hash` will take precedence
#
# @param simp_banner
#   The name of a banner from the `simp_banners` module that should be used
#
#   * Has no effect if `banner` is not set
#   * Has no effect if `banner_content` is set
#
# @param banner_content
#   The full content of the banner, without alteration
#
#   * GDM cannot handle '\n' sequences so any banner will need to have those
#     replaced with the literal '\n' string.
#
# @author https://github.com/simp/pupmod-simp-gdm/graphs/contributors
#
class gdm (
  Dconf::SettingsHash             $dconf_hash,
  Hash[String[1], Optional[Hash]] $packages,
  Gdm::CustomConf                 $settings,
  Simplib::PackageEnsure          $package_ensure   = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
  Boolean                         $include_sec      = true,
  Boolean                         $auditd           = simplib::lookup('simp_options::auditd', { 'default_value' => false }),
  Boolean                         $pam              = simplib::lookup('simp_options::pam', { 'default_value' => false }),
  Boolean                         $banner           = true,
  String[1]                       $simp_banner      = 'simp',
  String[1]                       $display_mgr_user = 'gdm',
  Optional[String[1]]             $banner_content   = undef
) {
  simplib::assert_metadata($module_name)

  include gdm::install
  include gdm::config
  include gdm::service

  Class['gdm::install'] -> Class['gdm::config']
  Class['gdm::install'] ~> Class['gdm::service']
  Class['gdm::config']  ~> Class['gdm::service']
}
