# @summary Configuration for /etc/gdm/custom.conf
type Gdm::CustomConf = Hash[
  Gdm::ConfSection,
  Hash[
    String[1],
    NotUndef
  ]
]
