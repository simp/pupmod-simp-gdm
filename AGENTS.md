# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`simp-gdm` is a SIMP Puppet module that installs, configures, and runs the
**GNOME Display Manager (GDM)** on Enterprise Linux systems. It installs the GDM
package set (plus a batch of legacy X11/font packages), writes settings to
`/etc/gdm/custom.conf` via `inifile`, applies GDM `dconf` settings (including a
login-screen banner) through the `dconf` module, and ensures the `gdm` service
is running. It optionally wires in PAM local-access rules for the display-manager
user and a `systemd-logind` dropin to cope with `hidepid`-mounted `/proc`.

The module is deliberately **not** in the business of switching the system
runlevel/target — `gdm::service` manages only the `gdm` service state, and the
acceptance suite has to set `runlevel { 'graphical' }` itself
(`manifests/service.pp:2-4`, `spec/acceptance/suites/default/00_default_spec.rb:10`).
GDM `dconf`/banner configuration is also **two-pass**: the config class only
emits the `dconf` profile/settings once the `gdm_version` fact is populated
(i.e. after GDM is installed), so the first Puppet run just installs and the
second run configures (`manifests/config.pp:17-20,85-87`).

### Business logic

Three private component classes orchestrated by the public `gdm` class, plus one
public defined type and a `service` class.

- **`gdm` (`manifests/init.pp:74-96`)** — Public entry class (consumers
  `include 'gdm'`; **not** `assert_private()`'d). Calls
  `simplib::assert_metadata($module_name)` (`init.pp:87`), then `include`s the
  three component classes and pins ordering (`init.pp:89-95`):
  `install -> config`, `install ~> service`, `config ~> service`. Key parameters
  (`init.pp:74-86`):
  - `$dconf_hash` (`Dconf::SettingsHash`, **no default**) — supplied from module
    data (`data/common.yaml:47-54`); GDM `dconf` settings, deep-merged with the
    banner settings.
  - `$packages` (`Hash[String[1], Optional[Hash]]`, **no default**) — the package
    list, from module data (`data/common.yaml:18-31`, augmented per-OS in
    `data/os/*.yaml`). Setting this **overrides** (deep-merges) the default list.
  - `$settings` (`Gdm::CustomConf`, **no default**) — from module data
    (`data/common.yaml:34-45`); each entry becomes a `gdm::set` in `gdm::config`.
  - `$package_ensure` (`Simplib::PackageEnsure`) — defaults to
    `simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })`
    (`init.pp:78`).
  - `$auditd` (`Boolean`) — defaults to
    `simplib::lookup('simp_options::auditd', { 'default_value' => false })`
    (`init.pp:80`). **NOTE: this parameter is accepted but never referenced
    anywhere else in the manifests** — there is no auditd resource in the module.
  - `$pam` (`Boolean`) — defaults to
    `simplib::lookup('simp_options::pam', { 'default_value' => false })`
    (`init.pp:81`); gates the PAM local-access rule in `gdm::install`.
  - `$include_sec` (`Boolean`, default `true`) — documented as having **no
    effect** (`init.pp:42-43,79`); accepted for backward compatibility only.
  - `$banner` (`Boolean`, default `true`), `$simp_banner` (`String[1]`, default
    `'simp'`), `$banner_content` (`Optional[String[1]]`, default `undef`) —
    control the login-screen banner (`init.pp:82,83,85`).
  - `$display_mgr_user` (`String[1]`, default `'gdm'`) — the local user granted
    PAM access when `$pam` is true (`init.pp:84`).

- **`gdm::install` (`manifests/install.pp:4-62`)** — `assert_private()` +
  `simplib::assert_metadata` (`install.pp:6,8`). Installs `$gdm::packages` via
  `simplib::install` with `ensure => $gdm::package_ensure`
  (`install.pp:10-15`). Two optional integrations:
  - **PAM branch** (`install.pp:17-27`): when `$gdm::pam`, asserts the optional
    `simp/pam` dependency and declares `pam::access::rule` allowing
    `$gdm::display_mgr_user` LOCAL access (order 1).
  - **hidepid/systemd branch** (`install.pp:30-58`): only when `systemd` is in
    the `init_systems` fact. If `/proc` is mounted with a positive/named
    `hidepid` (`1`/`2`/`'noaccess'`/`'invisible'`) **and** a `gid` is set, it
    asserts the optional `puppet/systemd` dependency and writes a
    `systemd::dropin_file` adding that GID to `systemd-logind.service`'s
    `SupplementaryGroups`, notifying `exec { 'gdm_restart_logind' }`
    (`systemctl restart systemd-logind`, `refreshonly`).

- **`gdm::config` (`manifests/config.pp:3-89`)** — `assert_private()`
  (`config.pp:4`). Iterates `$gdm::settings` and emits a `gdm::set` per
  section/key/value (`config.pp:7-15`). Then, **guarded on the `gdm_version`
  fact** (`config.pp:19`):
  - `fail()` if GDM version is between `0.0.0` and `3` — unsupported
    (`config.pp:20-22`).
  - Otherwise declares `dconf::profile { 'gdm' }` with user/system/file entries
    (`config.pp:24-38`), builds `$_banner_settings` from the `$banner` /
    `$banner_content` / `simp_banners::fetch($simp_banner)` logic
    (`config.pp:40-77`), and declares `dconf::settings { 'GDM Dconf Settings' }`
    with `deep_merge($_banner_settings, $gdm::dconf_hash)` (`config.pp:79-82`).
  - If `gdm_version` is **not** set, emits a `notify` telling the operator an
    additional Puppet run is needed (`config.pp:85-87`) — the two-pass behavior.

- **`gdm::service` (`manifests/service.pp:15-26`)** — public class (no
  `assert_private()`). Declares `service { 'gdm': ensure => running, enable =>
  true }` (`service.pp:18-21`). If `$services` is set **and** `svckill` exists
  (`simplib::module_exist('svckill')`), it declares `svckill::ignore` for those
  services so `svckill` won't disable them (`service.pp:23-25`). `$services`
  defaults to `undef` in the manifest but is populated from module data
  (`data/common.yaml:56-61`).

- **`gdm::set` (`manifests/set.pp:23-40`)** — public defined type. Writes one
  `ini_setting` into `/etc/gdm/custom.conf` for the given `$section`
  (`Gdm::ConfSection`), `$key`, `$value` (`set.pp:31-39`), `require`ing
  `Class['gdm::install']` and `notify`ing `Class['gdm::service']`. It also
  `include 'gdm'` (`set.pp:29`).

Custom data types (`types/`):
- **`Gdm::ConfSection`** (`types/confsection.pp:2-14`) — `Enum` of the valid
  `custom.conf` section names (`daemon`, `security`, `xdmcp`, `gui`, `greeter`,
  `chooser`, `debug`, `servers`, `server-Standard`, `server-Terminal`,
  `server-Chooser`).
- **`Gdm::CustomConf`** (`types/customconf.pp:2-8`) — `Hash[Gdm::ConfSection,
  Hash[String[1], NotUndef]]`; the shape of `$settings`.

### Gotchas / non-obvious details

- **Two-pass apply is required.** `gdm::config` only writes the `dconf`
  profile/settings once the `gdm_version` fact exists, which is only true after
  GDM is installed. The first run installs (and emits a `notify` about needing
  another run), the second run configures (`config.pp:17-20,85-87`; the
  acceptance spec runs the manifest twice, `00_default_spec.rb:34-45`).
- **The module does not change the runlevel/target.** `gdm::service` only
  manages the `gdm` service; switching to the graphical target is left to the
  operator (deliberately, to avoid lock-outs from bad graphics drivers —
  `service.pp:2-4`).
- **`$auditd` is dead weight.** It is a parameter with a `simp_options::auditd`
  lookup default (`init.pp:80`) but is never consumed anywhere in the manifests
  — there is no auditd integration despite the docstring (`init.pp:45-46`).
- **`$include_sec` has no effect** (`init.pp:42-43`) — accepted for
  backward-compatibility only.
- **`$packages` / `$settings` / `$dconf_hash` deep-merge** across the Hiera
  hierarchy with `knockout_prefix: --` (`hiera.yaml`, `data/common.yaml:2-14`),
  so per-OS data (`data/os/RedHat-8.yaml`, `RedHat-9.yaml`) *adds* legacy X11
  packages rather than replacing the common list.
- **`svckill::ignore` is best-effort.** `gdm::service` only calls it when
  `svckill` is actually present (`simplib::module_exist('svckill')`,
  `service.pp:23`) — `svckill` is a fixture, not a declared dependency.
- **Optional integrations are guarded at runtime** with
  `simplib::assert_optional_dependency` and a fact/param check
  (`install.pp:19,40`) — `simp/pam` and `puppet/systemd` are declared as
  `simp.optional_dependencies`, not hard deps.
- **`simp/simp_options` is NOT a declared dependency** in `metadata.json`, yet
  the manifest consumes the `simp_options::*` seam via `simplib::lookup`
  (provided by `simp/simplib`). `simp_options` appears only as a fixture
  (`.fixtures.yml:9`).
- **GDM cannot handle `\n`** in banner text — `banner_content` must use the
  literal `\n` string, and `simp_banners::fetch` is called with
  `cr_escape => true` (`init.pp:69-70`, `config.pp:50-53`).

## The `simp_options` / `simplib::lookup` seam

This is the module's SIMP feature-toggle seam. All calls are in
`manifests/init.pp`:

| Line | Key | `default_value` |
|------|-----|-----------------|
| `init.pp:78` | `simp_options::package_ensure` | `'installed'` |
| `init.pp:80` | `simp_options::auditd` | `false` (parameter is unused — see gotchas) |
| `init.pp:81` | `simp_options::pam` | `false` |

The rest of the module's real configuration surface is **plain module data**
(Hiera) rather than the `simp_options` seam: `gdm::packages`, `gdm::settings`,
`gdm::dconf_hash`, and `gdm::service::services` are all set in `data/common.yaml`
and merged per-OS from `data/os/*.yaml` (deep-merge with `knockout_prefix: --`,
`hiera.yaml`). Keep routing SIMP feature toggles through
`simplib::lookup('simp_options::*', { 'default_value' => ... })` with an explicit
default rather than assuming `simp_options` is included.

## Dependencies

Module dependencies (from `metadata.json`):

- `simp/simp_banners` `>= 0.1.0 < 2.0.0` (provides `simp_banners::fetch` for the
  login-screen banner text)
- `simp/dconf` `>= 0.0.1 < 2.0.0` (provides `dconf::profile`, `dconf::settings`,
  and the `Dconf::SettingsHash` type)
- `simp/simplib` `>= 4.9.0 < 6.0.0` (provides `simplib::lookup`,
  `simplib::assert_metadata`, `simplib::assert_optional_dependency`,
  `simplib::install`, `simplib::module_exist`, and the `gdm_version` /
  `init_systems` / `simplib__mountpoints` facts)
- `puppetlabs/inifile` `>= 2.5.0 < 7.0.0` (provides `ini_setting`, used by
  `gdm::set`)
- `puppetlabs/stdlib` `>= 8.0.0 < 10.0.0` (provides `deep_merge()`, `pick()`)

Optional dependencies (from `metadata.json` `simp.optional_dependencies`):

- `puppet/systemd` `>= 4.0.2 < 10.0.0` — used only for the `systemd-logind`
  hidepid dropin (`install.pp:40-49`).
- `simp/pam` `>= 6.8.3 < 10.0.0` — used only when `$pam` is true, for
  `pam::access::rule` (`install.pp:19-26`).

Fixture-only dependencies (from `.fixtures.yml`, present for test compilation /
acceptance, not runtime deps): `concat`, `polkit`, `simp_options`, `svckill`,
and (for acceptance) `oddjob`, `simp` — plus the runtime and optional deps above
are also checked out as fixtures.

Runtime requirement (from `metadata.json` `requirements`): `openvox
>= 8.0.0 < 9.0.0`.

Supported OS matrix (from `metadata.json`): CentOS 9/10; RedHat 8/9/10;
OracleLinux 8/9/10; Rocky 8/9/10; AlmaLinux 8/9/10.

## Repository layout

- `manifests/init.pp` — the public `gdm` class (parameters + orchestration).
- `manifests/install.pp` — `gdm::install` (private): packages, PAM rule, hidepid
  systemd dropin.
- `manifests/config.pp` — `gdm::config` (private): `custom.conf` settings +
  `dconf`/banner (two-pass, gated on `gdm_version`).
- `manifests/service.pp` — `gdm::service`: `gdm` service + `svckill` ignores.
- `manifests/set.pp` — `gdm::set` defined type: one `ini_setting` in
  `custom.conf`.
- `types/confsection.pp` — `Gdm::ConfSection` enum.
- `types/customconf.pp` — `Gdm::CustomConf` hash type.
- `data/common.yaml` — default `packages`, `settings`, `dconf_hash`,
  `service::services`, and per-key `lookup_options` (deep-merge).
- `data/os/RedHat-8.yaml`, `data/os/RedHat-9.yaml` — per-release extra legacy
  X11/font packages.
- `hiera.yaml` — module data hierarchy (v5): OS family+major.minor → OS
  family+major → common.
- `metadata.json` — deps, optional deps, OS matrix, openvox requirement.
- `spec/classes/init_spec.rb`, `spec/defines/set_spec.rb` — rspec-puppet unit
  tests.
- `spec/acceptance/suites/default/00_default_spec.rb`,
  `10_with_pam_and_proc_spec.rb` — beaker acceptance suites; nodesets under
  `spec/acceptance/nodesets/`.
- `REFERENCE.md` — generated Puppet Strings reference.
- No `lib/` or `templates/` — this module ships no Ruby types/providers/
  functions/facts and no ERB/EPP templates. It does have a `types/` directory
  (the two data types above); every function and fact it uses at runtime comes
  from the dependencies above.
- **Acceptance runs in CI:** `.github/workflows/pr_tests.yml` has an
  `acceptance` job (matrix `almalinux8`, `almalinux9`, `almalinux10`) whose final
  step runs `bundle exec rake beaker:suites[default,<node>]` under
  `BEAKER_HYPERVISOR=vagrant_libvirt`.

## Common commands

```sh
# Install dependencies
bundle install

# Run all unit tests
bundle exec rake spec

# Run the single class spec
bundle exec rspec spec/classes/init_spec.rb

# Puppet lint
bundle exec rake lint

# Ruby lint
bundle exec rake rubocop

# Regenerate REFERENCE.md from puppet-strings docstrings
puppet strings generate --format markdown --out REFERENCE.md

# Run the default beaker acceptance suite
bundle exec rake beaker:suites[default]
```

Relevant gem pins (from `Gemfile`): `puppetlabs_spec_helper ~> 8.0.0`,
`simp-rake-helpers ~> 5.24.0`, `simp-rspec-puppet-facts ~> 4.0.0`,
`simp-beaker-helpers ~> 2.0.0`. Rubocop is pinned to `~> 1.88.0`. The test group
pins both `openvox` and `puppet` at `>= 8 < 9` (the puppet gem is kept
temporarily until it is dropped from other gems).

## Conventions

- Preserve the `@summary` / `@param` puppet-strings docstrings on the classes and
  the `gdm::set` define — they drive `REFERENCE.md`. Regenerate `REFERENCE.md`
  after changing docs or parameters.
- Keep the package/settings/dconf/service data in module data (`data/*.yaml`),
  not hard-coded in the manifests; rely on the deep-merge + `knockout_prefix: --`
  hierarchy for per-OS overrides.
- Continue routing SIMP feature toggles through
  `simplib::lookup('simp_options::*', { 'default_value' => ... })` rather than
  assuming `simp_options` is included.
- Guard optional integrations (`simp/pam`, `puppet/systemd`, `svckill`) with
  `simplib::assert_optional_dependency` / `simplib::module_exist` and a
  fact/param check, as `gdm::install` and `gdm::service` do — don't hard-`include`
  optional modules.
- Respect the two-pass model: configuration that depends on the `gdm_version`
  fact must tolerate the fact being absent on the first run (`config.pp:19,85`).
- `Gemfile`, `spec/spec_helper.rb`, `.pdkignore`, `.gitignore`, and the
  `.github/workflows/` files carry a **puppetsync** notice — they are
  baseline-managed and the next sync overwrites local edits. Push changes to
  those files upstream to the baseline, not here.
- Match the existing 2-space Puppet indentation and aligned-arrow parameter style
  used across `manifests/`.
