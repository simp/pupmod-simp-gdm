# Provides default GDM package install list
#
# @return Array[String]
#
function gdm::packages() {

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

  $os_packages = case $facts['operatingsystemmajrelease'] {
    '7': { [
        'xorg-x11-utils',
        'xorg-x11-docs'
    ] }
    '6': { [
        'xorg-x11-apps',
        'xorg-x11-twm',
        'xterm',
        'dejavu-lgc-sans-fonts',
        'dejavu-lgc-sans-mono-fonts',
        'dejavu-lgc-serif-fonts',
        'bitmap-console-fonts',
        'bitmap-fangsongti-fonts',
        'bitmap-fonts-compat',
        'bitmap-miscfixed-fonts'
      ] }
    default: {[]}
  }

  $common_packages + $os_packages
}
