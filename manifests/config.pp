# Configuration items for GDM
#
#
class gdm::config {
  assert_private()

  dconf::profile { 'gdm':
    entries => {
      'user' => {
        'type' => 'user',
        'order' => 1
      },
      'gdm' => {
        'type' => 'system'
      },
      '/usr/share/gdm/greeter-dconf-defaults' => {
        'type' => 'file',
        'order' => 99
      }
    }
  }

  $gdm::dconf_hash.each |String $profile_name, Hash $profiles| {
    dconf::settings { "GDM Dconf Settings for #{$profile_name}":
      profile       => $profile_name,
      settings_hash => $profiles
    }
  }
}
