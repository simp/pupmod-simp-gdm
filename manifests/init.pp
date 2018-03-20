# This class configures, installs, and ensures GDM is running.
#
# @param include_sec Boolean
# Whether or not to include gdm::sec
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
# @author Nick Markowski <nmarkowski@keywcorp.com>
#
class gdm (
  Boolean $include_sec = true,
  Boolean $auditd      = simplib::lookup('simp_options::auditd', { 'default_value' => false })
) {

  simplib::assert_metadata($module_name)

  include '::gdm::install'

  # If GDM isn't installed, this won't actually exist so we need a two pass run
  # to get this right
  if $facts['gdm_version'] {
    include '::gdm::service'

    if $include_sec {
      include '::gdm::sec'
    }

    if ( versioncmp($facts['gdm_version'], '3') < 0 ) and ( versioncmp($facts['gdm_version'], '0.0.0') > 0 ) {
      # Set the desktop variable
      file { '/etc/sysconfig/desktop':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "DESKTOP='GNOME'\n"
      }

      # Audit the default gdm system-wide configuration file.
      if $auditd {
        auditd::rule { 'system_gdm':
          content => '-w /usr/share/gdm/defaults.conf -p wa -k CFG_sys'
        }
      }
    }

    Class['gdm::install'] ~>
    Class['gdm::service'] ->
    Class['gdm']
  }
  else {
    notify { "Additional Puppet Run Needed for ${module_name}": }
  }
}
