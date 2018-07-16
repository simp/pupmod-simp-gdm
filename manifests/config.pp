# Configuration items for GDM
#
#
class gdm::config {
  assert_private()

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
