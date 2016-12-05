# Provides default values for parameters
#
# @return Undef
#
function gdm::data() {

  $common_packages = [
    'gdm',
    'xorg-x11-fonts-100dpi',
    'xorg-x11-fonts-75dpi',
    'xorg-x11-fonts-ISO8859-1-100dpi',
    'xorg-x11-fonts-ISO8859-1-75dpi',
    'xorg-x11-fonts-Type1',
    'xorg-x11-fonts-misc',
    'xorg-x11-server-Xorg',
    'xorg-x11-drivers',
    'xorg-x11-xinit',
    'dejavu-sans-fonts',
    'dejavu-sans-mono-fonts',
    'dejavu-serif-fonts',
    'bitmap-fixed-fonts',
    'bitmap-lucida-typewriter-fonts',
    'liberation-mono-fonts',
    'liberation-sans-fonts',
    'liberation-serif-fonts'
  ]

  $os_params = case $facts['operatingsystemmajrelease'] {
    '7': {
      { 'gdm::install::package_list' => [
        'xorg-x11-utils',
        'xorg-x11-docs',
        $common_packages
      ]}
    }
    '6': {
      { 'gdm::install::package_list' => [
        'xorg-x11-apps',
        'xorg-x11-twm',
        'xterm',
        'dejavu-lgc-sans-fonts',
        'dejavu-lgc-sans-mono-fonts',
        'dejavu-lgc-serif-fonts',
        'bitmap-console-fonts',
        'bitmap-fangsongti-fonts',
        'bitmap-fonts-compat',
        'bitmap-miscfixed-fonts',
        $common_packages
      ]}
    }
    default: {
      {}
    }
  }

  $base_params = {
    'gdm::include_sec' => true
  }

  $base_params + $os_params
}
