# @summary This define allows you to set individual configuration elements in
# `/etc/gdm/custom.conf` without explicitly needing to use an `inifile`
# resource.
#
# If you wish to simply use `inifile`, that is perfectly valid!
#
# For particular configuration parameters, please see:
#   http://projects.gnome.org/gdm/docs/2.16/configuration.html
#
# @param section
#   The section that you wish to manipulate.  Valid values are 'daemon',
#   'security','xdmcp', 'gui','greeter', 'chooser', 'debug', 'servers',
#   'server-Standard', 'server-Terminal', and 'server-Chooser'
#
# @param key
#   The actual key value that you wish to change under $section.
#
# @param value
#   The value to which $key should be set under $section
#
# @param key_val_separator
#   The character(s) placed between the key and value in
#   `/etc/gdm/custom.conf`.
#
#   * Defaults to ` = `, matching the historical output of the
#     `puppetlabs/inifile` module
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
define gdm::set (
  Gdm::ConfSection        $section,
  String                  $key,
  Variant[Boolean,String] $value,
  String[1]               $key_val_separator = ' = '
) {

  include 'gdm'

  ini_setting { "GDM custom config ${name}":
    ensure            => 'present',
    path              => '/etc/gdm/custom.conf',
    section           => $section,
    setting           => $key,
    value             => $value,
    key_val_separator => $key_val_separator,
    require           => Class['gdm::install'],
    notify            => Class['gdm::service']
  }
}
