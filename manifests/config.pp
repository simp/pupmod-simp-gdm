# @summary Configuration items for GDM
#
class gdm::config {
  assert_private()

  # Version agnostic settings
  $gdm::settings.each |Gdm::ConfSection $section, NotUndef $section_settings| {
    $section_settings.each |String $key, $value| {
      gdm::set { "GDM [${section}] ${key}:${value}":
        section => $section,
        key     => $key,
        value   => $value
      }
    }
  }

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
      if $gdm::auditd {
        auditd::rule { 'system_gdm':
          content => '-w /usr/share/gdm/defaults.conf -p wa -k CFG_sys'
        }
      }
    }
    else {
      dconf::profile { 'gdm':
        entries => {
          'user' => {
            'type'  => 'user',
            'order' => 1
          },
          'gdm'  => {
            'type' => 'system'
          },
          '/usr/share/gdm/greeter-dconf-defaults' => {
            'type'  => 'file',
            'order' => 99
          }
        }
      }

      if $gdm::banner {
        if $gdm::banner_content {
          if $gdm::banner_content[0] == "'" {
            $_banner_text = $gdm::banner_content
          }
          else {
            $_banner_text = "'${gdm::banner_content}'"
          }
        }
        else {
          $_tmp_text = simp_banners::fetch(
            $gdm::simp_banner,
            { 'cr_escape' => true }
          )

          $_banner_text = "'${_tmp_text}'"
        }

        $_banner_settings = {
          'org/gnome/login-screen' => {
            'banner-message-enable' => {
              'value' => true
            },
            'banner-message-text' => {
              'value' => $_banner_text
            }
          }
        }
      }
      else {
        $_banner_settings = {
          'org/gnome/login-screen' => {
            'banner-message-enable' => {
              'value' => false
            }
          }
        }
      }

      dconf::settings { 'GDM Dconf Settings':
        profile       => 'gdm',
        settings_hash => deep_merge($_banner_settings, $gdm::dconf_hash)
      }
    }
  }
  else {
    notify { "Additional Puppet Run Needed for ${module_name}": }
  }
}
