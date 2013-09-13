# Proxy Configuration Plugin for Vagrant

<span class="badges">
[![Gem Version](https://badge.fury.io/rb/vagrant-proxyconf.png)][gem]
[![Build Status](https://travis-ci.org/tmatilai/vagrant-proxyconf.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/tmatilai/vagrant-proxyconf.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/tmatilai/vagrant-proxyconf.png)][codeclimate]
</span>

[gem]: https://rubygems.org/gems/vagrant-proxyconf
[travis]: https://travis-ci.org/tmatilai/vagrant-proxyconf
[gemnasium]: https://gemnasium.com/tmatilai/vagrant-proxyconf
[codeclimate]: https://codeclimate.com/github/tmatilai/vagrant-proxyconf

A [Vagrant](http://www.vagrantup.com/) plugin that configures the virtual machine to use specified proxies. This is useful for example in case you are behind a corporate proxy, or you have a caching proxy.

At this state we support:

* Generic `*_proxy` environment variables that many programs support
* APT proxy/cacher
* Setting default proxy configuration for all Chef provisioners

Support is planned for other package managers (at least yum).

## Compatibility

This plugin requires Vagrant 1.2 or newer ([downloads](http://downloads.vagrantup.com/)).

The plugin is supposed to be compatible with all Vagrant providers. Please file an [issue](https://github.com/tmatilai/vagrant-proxyconf/issues) if this is not the case.
The following providers are confirmed to work:
[AWS](https://github.com/mitchellh/vagrant-aws),
[Digital Ocean](https://github.com/smdahlen/vagrant-digitalocean),
[VirtualBox](http://docs.vagrantup.com/v2/virtualbox),
[VMware Fusion](http://docs.vagrantup.com/v2/vmware/index.html).

For the proxy configuration to take effect for [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus) plugin, version 1.1.1 or newer of it should be used.

## Installation

Install using standard Vagrant plugin installation method:

```sh
vagrant plugin install vagrant-proxyconf
```

See the [wiki](https://github.com/tmatilai/vagrant-proxyconf/wiki) for instructions to install a pre-release version.

## Usage

The plugin hooks itself to all Vagrant commands triggering provisioning (e.g. `vagrant up`, `vagrant provision`, etc.). The proxy configurations are written just before provisioners are run.

Proxy settings can be configured in Vagrantfile. In the common case that you want to use the same configuration in all Vagrant machines, you can use _$HOME/.vagrant.d/Vagrantfile_ or environment variables. Platform specific settings are only used on virtual machines that support them (i.e. Apt configuration on Debian based systems), so there is no harm using global configuration.

Project specific Vagrantfile overrides global settings. Environment variables override both.

### Default/global configuration

It's a common case that you want all possible connections to pass through the same proxy. This will set the default values for all other proxy configuration keys. It also sets default proxy configuration for all Chef Solo and Chef Client provisioners.

#### Example Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  config.proxy.http     = "http://192.168.0.2:3128/"
  config.proxy.https    = "http://192.168.0.2:3128/"
  config.proxy.no_proxy = "localhost,127.0.0.1,.example.com"
  # ... other stuff
end
```

#### Configuration keys

* `config.proxy.http` - The proxy for HTTP URIs
* `config.proxy.https` - The proxy for HTTPS URIs
* `config.proxy.ftp` - The proxy for FTP URIs
* `config.proxy.no_proxy` - A comma separated list of hosts or domains which do not use proxies.

#### Possible values

* If all keys are unset or `nil`, no configuration is written.
* A proxy should be specified in the form of _protocol://[user:pass@]host[:port]_.
* Empty string (`""`) or `false` in any setting also force the configuration files to be written, but without configuration for that key. Can be used to clear the old configuration and/or override a global setting.

#### Environment variables

* `VAGRANT_HTTP_PROXY`
* `VAGRANT_HTTPS_PROXY`
* `VAGRANT_FTP_PROXY`
* `VAGRANT_NO_PROXY`

These also override the Vagrantfile configuration. To disable or remove the proxy use an empty value.

For example to spin up a VM, run:

```sh
VAGRANT_HTTP_PROXY="http://proxy.example.com:8080" vagrant up
```

### Global `*_proxy` environment variables

Many programs (wget, curl, yum, etc.) can be configured to use proxies with `<protocol>_proxy` or `<PROTOCOL>_PROXY` environment variables. This configuration will be written to _/etc/profile.d/proxy.sh_ on the guest.

Also sudo will be configured to preserve the variables. This requires that sudo in the VM is configured to support "sudoers.d", i.e. _/etc/sudoers_ contains line `#includedir /etc/sudoers.d`.

#### Example Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  config.env_proxy.http     = "http://192.168.33.200:8888/"
  config.env_proxy.https    = "$http_proxy"
  config.env_proxy.no_proxy = "localhost,127.0.0.1,.example.com"
  # ... other stuff
end
```

#### Configuration keys

* `config.env_proxy.http` - The proxy for HTTP URIs
* `config.env_proxy.https` - The proxy for HTTPS URIs
* `config.env_proxy.ftp` - The proxy for FTP URIs
* `config.env_proxy.no_proxy` - A comma separated list of hosts or domains which do not use proxies.

#### Possible values

* If all keys are unset or `nil`, no configuration is written.
* A proxy can be specified in the form of _protocol://[user:pass@]host[:port]_.
* The values are used as specified, so you can use for example variables that will be evaluated by the shell on the VM.
* Empty string (`""`) or `false` in any setting also force the configuration file to be written, but without configuration for that key. Can be used to clear the old configuration and/or override a global setting.

#### Environment variables

* `VAGRANT_ENV_HTTP_PROXY`
* `VAGRANT_ENV_HTTPS_PROXY`
* `VAGRANT_ENV_FTP_PROXY`
* `VAGRANT_ENV_NO_PROXY`

These also override the Vagrantfile configuration. To disable or remove the proxy use an empty value.

For example to spin up a VM, run:

```sh
VAGRANT_ENV_HTTP_PROXY="http://proxy.example.com:8080" vagrant up
```

### Apt

Configures Apt to use the specified proxy settings. The configuration will be written to _/etc/apt/apt.conf.d/01proxy_ on the guest.

#### Example Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  config.apt_proxy.http  = "192.168.33.1:3142"
  config.apt_proxy.https = "DIRECT"
  # ... other stuff
end
```

#### Configuration keys

* `config.apt_proxy.http`  - The proxy for HTTP URIs
* `config.apt_proxy.https` - The proxy for HTTPS URIs
* `config.apt_proxy.ftp`   - The proxy for FTP URIs

#### Possible values

* If all keys are unset or `nil`, no configuration is written.
* A proxy can be specified in the form of _[http://][user:pass@]host[:port]_. So all but the _host_ part are optional. The default port is 3142 and protocol is the same as the key.
* Empty string (`""`) or `false` in any protocol also force the configuration file to be written, but without configuration for that protocol. Can be used to clear the old configuration and/or override a global setting.
* `"DIRECT"` can be used to specify that no proxy should be used. This is mostly useful for disabling proxy for HTTPS URIs when HTTP proxy is set (as Apt defaults to the latter).
* Please refer to [apt.conf(5)](http://manpages.debian.net/man/5/apt.conf) manual for more information.

#### Environment variables

* `VAGRANT_APT_HTTP_PROXY`
* `VAGRANT_APT_HTTPS_PROXY`
* `VAGRANT_APT_FTP_PROXY`

These also override the Vagrantfile configuration. To disable or remove the proxy use "DIRECT" or an empty value.

For example to spin up a VM, run:

```sh
VAGRANT_APT_HTTP_PROXY="proxy.example.com:8080" vagrant up
```

#### Running apt-cacher-ng on a Vagrant box

[Here](https://github.com/tmatilai/apt-cacher-box) is an example for setting up apt-cacher proxy server in a Vagrant VM.

## Related plugins and projects

* [apt-cacher-box](https://github.com/tmatilai/apt-cacher-box)<br/>
  a Vagrant setup for apt-cacher-ng.
* [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier)<br/>
  An excellent Vagrant plugin that shares various cache directories among similar VM instances. Should work fine together with vagrant-proxyconf.
* [vagrant-httpproxy](https://github.com/juliandunn/vagrant-httpproxy)<br/>
  A Chef cookbook for configuring Chef resources to use the specified proxy (while offline).
* [vagrant-proxy](https://github.com/clintoncwolfe/vagrant-proxy)<br/>
  A Vagrant plugin that uses iptables rules to force the VM to use a proxy.
