[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/gdm.svg)](https://forge.puppetlabs.com/simp/gdm)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/gdm.svg)](https://forge.puppetlabs.com/simp/gdm)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-gdm.svg)](https://travis-ci.org/simp/pupmod-simp-gdm)

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [This is a SIMP module](#this-is-a-simp-module)
* [Module Description](#module-description)
* [Setup](#setup)
  * [What gdm affects](#what-gdm-affects)
* [Usage](#usage)
* [Reference](#reference)
* [Development](#development)

<!-- vim-markdown-toc -->

## This is a SIMP module

This module is a component of the
[System Integrity Management Platform](https://simp-project.com),
a compliance-management framework built on Puppet.

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net/).

## Module Description

`simp-gdm` provides the ability to manage GDM on supported systems.

## Setup

### What gdm affects

`gdm` installs the GNOME Display Manager and sets sensible defaults.

The module has the ability to configure GDM settings via `dconf`.

## Usage

Generally, you only need to use `include gdm` to get full management.

In the case that you have `hidepid=2` set on `/proc`, you may need to run puppet
one additional time to allow the facts to hook into the system fully.

## Reference

See [REFERENCE.md](./REFERENCE.md)

## Development

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

If you find any issues, they can be submitted to our [JIRA](https://simp-project.atlassian.net).

