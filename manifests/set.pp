# This define allows you to set individual configuration elements in
# /etc/gdm/custom.conf without explicitly needing to specify all of the augeas
# parameters.
#
# If you wish to simply use the augeas type, that is perfectly valid!
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
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
define gdm::set (
  Enum[ 'daemon', 'security', 'xdmcp', 'gui', 'greeter', 'chooser', 'debug',
  'servers', 'server-Standard', 'server-Terminal', 'server-Chooser' ] $section,
  String $key,
  Variant[Boolean,String] $value
) {
  augeas { "gdm_set_${name}":
    incl    => '/etc/gdm/custom.conf',
    lens    => 'Gdm.lns',
    changes => [ "set ${section}/${key} '${value}'" ],
    require => Package['gdm']
  }
}
