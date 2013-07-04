# Vagrant Proxy Configuration Plugin

[![Gem Version](https://badge.fury.io/rb/vagrant-proxyconf.png)][gem]
[![Build Status](https://travis-ci.org/tmatilai/vagrant-proxyconf.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/tmatilai/vagrant-proxyconf.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/tmatilai/vagrant-proxyconf.png)][codeclimate]

[gem]: https://rubygems.org/gems/vagrant-proxyconf
[travis]: https://travis-ci.org/tmatilai/vagrant-proxyconf
[gemnasium]: https://gemnasium.com/tmatilai/vagrant-proxyconf
[codeclimate]: https://codeclimate.com/github/tmatilai/vagrant-proxyconf

A [Vagrant](http://www.vagrantup.com/) plugin that configures the virtual machine to use specified proxies for package managers etc.

At this state we support:

* [APT](http://en.wikipedia.org/wiki/Advanced_Packaging_Tool) proxy/cacher

Support is planned for other package managers (at least yum).

## Installation

**Note:** This plugin requires Vagrant v1.2 or newer ([downloads](http://downloads.vagrantup.com/)).

Install using standard Vagrant plugin installation method:
```sh
vagrant plugin install vagrant-proxyconf
```

## Usage

Proxy settings can be configured in Vagrantfile. In the common case that you want to use the same configuration in all Vagrant machines, you can use _$HOME/.vagrant.d/Vagrantfile_ or environment variables. Package manager specific settings are only used on supporting platforms (i.e. Apt configuration on Debian based systems), so there is no harm using global configuration.

Project specific Vagrantfile overrides global settings. Environment variables override both.

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

* `APT_PROXY_HTTP`
* `APT_PROXY_HTTPS`
* `APT_PROXY_FTP`

These also override the Vagrantfile configuration. To disable or remove the proxy use "DIRECT" or an empty value.

For example to spin up a VM, run:
```sh
APT_PROXY_HTTP="proxy.example.com:8080" vagrant up
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
