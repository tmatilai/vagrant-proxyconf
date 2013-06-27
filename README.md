# Vagrant Proxy Configuration Plugin

[![Gem Version](https://badge.fury.io/rb/vagrant-proxyconf.png)][gem]
[![Build Status](https://travis-ci.org/tmatilai/vagrant-proxyconf.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/tmatilai/vagrant-proxyconf.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/tmatilai/vagrant-proxyconf.png)][codeclimate]

[gem]: https://rubygems.org/gems/vagrant-proxyconf
[travis]: https://travis-ci.org/tmatilai/vagrant-proxyconf
[gemnasium]: https://gemnasium.com/tmatilai/vagrant-proxyconf
[codeclimate]: https://codeclimate.com/github/tmatilai/vagrant-proxyconf

A [Vagrant](http://www.vagrantup.com/) 1.1+ plugin that configures the virtual machine to use specified proxies for package managers etc.

At this state we support:

- [APT](http://en.wikipedia.org/wiki/Advanced_Packaging_Tool) proxy/cacher

Support is planned for other package managers (at least yum).

## Usage

Install using standard Vagrant 1.1+ plugin installation method:
```sh
vagrant plugin install vagrant-proxyconf
```

### Apt

The proxy for Apt can be specified in the Vagrantfile:
```ruby
Vagrant.configure("2") do |config|

  config.apt_proxy.http = "192.168.33.1:3142"

  # ... other stuff
end
```

The proxy can be specified as an IP address, name or full URL, with optional port (defaults to 3142).

You can also use `APT_PROXY_HTTP` and `APT_PROXY_HTTPS` environment variables. These override the Vagrantfile configuration. To disable or remove the proxy use "DIRECT" or an empty value.

Proxy settings will be written to _/etc/apt/apt.conf.d/01proxy_ on the guest.

[Here](https://github.com/tmatilai/apt-cacher-box) is an example for setting up apt-cacher proxy in a Vagrant VM.

## Related plugins and projects

- [apt-cacher-box](https://github.com/tmatilai/apt-cacher-box) (Vagrant setup for apt-cacher-ng)
- [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier) (Vagrant plugin)
- [vagrant-httpproxy](https://github.com/juliandunn/vagrant-httpproxy) (Chef cookbook)
- [vagrant-proxy](https://github.com/clintoncwolfe/vagrant-proxy) (Vagrant plugin)
