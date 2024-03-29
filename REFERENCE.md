# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

#### Public Classes

* [`gdm`](#gdm): This class configures, installs, and ensures GDM is running.
* [`gdm::config`](#gdm--config): Configuration items for GDM
* [`gdm::service`](#gdm--service): Ensures the GDM service is properly configured

#### Private Classes

* `gdm::install`: Install the GDM components

### Defined types

* [`gdm::set`](#gdm--set): This define allows you to set individual configuration elements in

### Data types

* [`Gdm::ConfSection`](#Gdm--ConfSection): Top level sections in /etc/gdm/custom.conf
* [`Gdm::CustomConf`](#Gdm--CustomConf): Configuration for /etc/gdm/custom.conf

## Classes

### <a name="gdm"></a>`gdm`

@see dconf(5)
 @see data/common.yaml

#### Parameters

The following parameters are available in the `gdm` class:

* [`dconf_hash`](#-gdm--dconf_hash)
* [`packages`](#-gdm--packages)
* [`settings`](#-gdm--settings)
* [`package_ensure`](#-gdm--package_ensure)
* [`include_sec`](#-gdm--include_sec)
* [`auditd`](#-gdm--auditd)
* [`pam`](#-gdm--pam)
* [`display_mgr_user`](#-gdm--display_mgr_user)
* [`banner`](#-gdm--banner)
* [`simp_banner`](#-gdm--simp_banner)
* [`banner_content`](#-gdm--banner_content)

##### <a name="-gdm--dconf_hash"></a>`dconf_hash`

Data type: `Dconf::SettingsHash`

``dconf`` settings applicable to GDM

##### <a name="-gdm--packages"></a>`packages`

Data type: `Hash[String[1], Optional[Hash]]`

A Hash of packages to be installed

* NOTE: Setting this will *override* the default package list
* The ensure value can be set in the hash of each package, like the example
  below:

@example Override packages
  { 'gdm' => { 'ensure' => '1.2.3' } }

@see data/common.yaml

##### <a name="-gdm--settings"></a>`settings`

Data type: `Gdm::CustomConf`

A Hash of settings that will be applied to `/etc/gdm/custom.conf`

The top-level section keys are well defined but the sub-keys will not be
validated

@example Set [chooser] and [daemon] options
  {
    'chooser' => {
      'Multicast' => 'false'
    },
    'daemon' => {
      'TimedLoginEnable' => 'false'
      'TimedLoginDelay' => 30
    }
  }

##### <a name="-gdm--package_ensure"></a>`package_ensure`

Data type: `Simplib::PackageEnsure`

The SIMP global catalyst to set the default `ensure` settings for packages
managed with this module.

Default value: `simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })`

##### <a name="-gdm--include_sec"></a>`include_sec`

Data type: `Boolean`

Boolean
This no longer has any effect

Default value: `true`

##### <a name="-gdm--auditd"></a>`auditd`

Data type: `Boolean`

Enable auditd support for this module via the ``simp-auditd`` module

Default value: `simplib::lookup('simp_options::auditd', { 'default_value' => false })`

##### <a name="-gdm--pam"></a>`pam`

Data type: `Boolean`

Enable pam support for this module via the ``simp-pam`` module

Default value: `simplib::lookup('simp_options::pam', { 'default_value' => false })`

##### <a name="-gdm--display_mgr_user"></a>`display_mgr_user`

Data type: `String[1]`

The name of the local user that runs the display manager.  If pam is enabled
this user will be given local access to the system to it can start the service.

Default value: `'gdm'`

##### <a name="-gdm--banner"></a>`banner`

Data type: `Boolean`

Enable a login screen banner

* NOTE: any banner settings set via `dconf_hash` will take precedence

Default value: `true`

##### <a name="-gdm--simp_banner"></a>`simp_banner`

Data type: `String[1]`

The name of a banner from the `simp_banners` module that should be used

* Has no effect if `banner` is not set
* Has no effect if `banner_content` is set

Default value: `'simp'`

##### <a name="-gdm--banner_content"></a>`banner_content`

Data type: `Optional[String[1]]`

The full content of the banner, without alteration

* GDM cannot handle '\n' sequences so any banner will need to have those
  replaced with the literal '\n' string.

Default value: `undef`

### <a name="gdm--config"></a>`gdm::config`

Configuration items for GDM

### <a name="gdm--service"></a>`gdm::service`

This will **NOT** switch the runlevel by default since this is a potentially
dangerous activity if graphics drivers are having issues.

#### Parameters

The following parameters are available in the `gdm::service` class:

* [`services`](#-gdm--service--services)

##### <a name="-gdm--service--services"></a>`services`

Data type: `Optional[Array[String[1]]]`

A list of services relevant to the proper functioning of GDM

* These services will *not* be individually managed. Instead, this list
  will be used for ensuring that the services are not disabled by the
  `svckill` module if it is present.

Default value: `undef`

## Defined types

### <a name="gdm--set"></a>`gdm::set`

`/etc/gdm/custom.conf` without explicitly needing to use an `inifile`
resource.

If you wish to simply use `inifile`, that is perfectly valid!

For particular configuration parameters, please see:
  http://projects.gnome.org/gdm/docs/2.16/configuration.html

#### Parameters

The following parameters are available in the `gdm::set` defined type:

* [`section`](#-gdm--set--section)
* [`key`](#-gdm--set--key)
* [`value`](#-gdm--set--value)

##### <a name="-gdm--set--section"></a>`section`

Data type: `Gdm::ConfSection`

The section that you wish to manipulate.  Valid values are 'daemon',
'security','xdmcp', 'gui','greeter', 'chooser', 'debug', 'servers',
'server-Standard', 'server-Terminal', and 'server-Chooser'

##### <a name="-gdm--set--key"></a>`key`

Data type: `String`

The actual key value that you wish to change under $section.

##### <a name="-gdm--set--value"></a>`value`

Data type: `Variant[Boolean,String]`

The value to which $key should be set under $section

## Data types

### <a name="Gdm--ConfSection"></a>`Gdm::ConfSection`

Top level sections in /etc/gdm/custom.conf

Alias of `Enum['daemon', 'security', 'xdmcp', 'gui', 'greeter', 'chooser', 'debug', 'servers', 'server-Standard', 'server-Terminal', 'server-Chooser']`

### <a name="Gdm--CustomConf"></a>`Gdm::CustomConf`

Configuration for /etc/gdm/custom.conf

Alias of

```puppet
Hash[Gdm::ConfSection, Hash[
    String[1],
    NotUndef
  ]]
```

