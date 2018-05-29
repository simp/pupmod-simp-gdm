# Configuration items for GDM
#
#
class gdm::config {
  assert_private()

  gnome::dconf::profile { 'gdm':
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

  $_db_dirs = flatten($gdm::dconf_hash.keys.map |$profile| {
    ["/etc/dconf/db/${profile}.d", "/etc/dconf/db/${profile}.d/locks"]
  })

  ensure_resource('file', $_db_dirs, {
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    recurse => true,
    purge   => true
  })

  $gdm::dconf_hash.each |String $profile_name, Hash $profiles| {
    $profiles.each |String $path, Hash $settings| {
      gnome::dconf { "${profile_name} ${path}":
        path          => $path,
        profile       => $profile_name,
        settings_hash => $settings
      }
    }
  }
}
