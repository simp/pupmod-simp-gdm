# @summary Install the GDM components
#
# @api private
class gdm::install {

  assert_private()

  simplib::assert_metadata($module_name)

  $_package_defaults = { 'ensure' => $gdm::package_ensure }

  simplib::install { 'gdm packages':
    packages => $gdm::packages,
    defaults => $_package_defaults
  }

  if $gdm::pam {

    simplib::assert_optional_dependency($module_name, 'simp/pam')

    pam::access::rule { 'allow_local_display_manager':
      permission => '+',
      users      => [$gdm::display_mgr_user],
      origins    => ['LOCAL'],
      order      => 1
    }
  }

  # Allow systemd-logind to see  files in /proc
  if 'systemd' in pick($facts.dig('init_systems') , []) {
    # If hidepid is enabled and a GID is set, then the systemd-logind service
    # must have that GID added to its supplementary groups at start time.
    # Depending on the kernel/util-linux version, the fact reports hidepid
    # either numerically (1, 2) or by name ('noaccess', 'invisible').
    $_hidepid = pick($facts.dig('simplib__mountpoints', '/proc', 'options_hash', 'hidepid'), 0)
    if ($_hidepid =~ Integer and $_hidepid > 0) or ($_hidepid in ['noaccess', 'invisible']) {
      $_proc_gid = $facts.dig('simplib__mountpoints', '/proc', 'options_hash', 'gid')

      if $_proc_gid {
        simplib::assert_optional_dependency($module_name, 'puppet/systemd')

        systemd::dropin_file { "${module_name}_hidepid.conf":
          unit    => 'systemd-logind.service',
          notify  => Exec['gdm_restart_logind'],
          content => @("SYSTEMD_OVERRIDE")
            [Service]
            SupplementaryGroups=${_proc_gid}
            | SYSTEMD_OVERRIDE
        }

        # Need to restart the logind daemon for it pick up the change.
        exec { 'gdm_restart_logind':
          command     => 'systemctl restart systemd-logind',
          refreshonly => true,
          path        => ['/usr/sbin','/usr/bin']
        }
      }
    }
  }


}
