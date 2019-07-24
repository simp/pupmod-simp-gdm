# @summary Top level sections in /etc/gdm/custom.conf
type Gdm::ConfSection = Enum[
  'daemon',
  'security',
  'xdmcp',
  'gui',
  'greeter',
  'chooser',
  'debug',
  'servers',
  'server-Standard',
  'server-Terminal',
  'server-Chooser'
]
