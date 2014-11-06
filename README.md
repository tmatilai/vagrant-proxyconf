# Proxy Configuration Plugin for Vagrant

<span class="badges">
[![Gem Version](https://badge.fury.io/rb/vagrant-proxyconf.png)][gem]
[![Build Status](https://travis-ci.org/tmatilai/vagrant-proxyconf.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/tmatilai/vagrant-proxyconf.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/tmatilai/vagrant-proxyconf.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/tmatilai/vagrant-proxyconf/badge.png)][coveralls]
</span>

[gem]: https://rubygems.org/gems/vagrant-proxyconf
[travis]: https://travis-ci.org/tmatilai/vagrant-proxyconf
[gemnasium]: https://gemnasium.com/tmatilai/vagrant-proxyconf
[codeclimate]: https://codeclimate.com/github/tmatilai/vagrant-proxyconf
[coveralls]: https://coveralls.io/r/tmatilai/vagrant-proxyconf

A [Vagrant](http://www.vagrantup.com/) plugin that configures the virtual machine to use specified proxies. This is useful for example in case you are behind a corporate proxy server, or you have a caching proxy (for example [polipo](https://github.com/tmatilai/polipo-box)).

The plugin can set:

* generic `http_proxy` etc. environment variables that many programs support
* default proxy configuration for all Chef provisioners
* proxy configuration for Apt
* proxy configuration for docker
* proxy configuration for Git
* proxy configuration for npm
* proxy configuration for Yum
* proxy configuration for PEAR
* proxy configuration for Subversion
* simple proxy configuration for Windows

## Quick start

Install the plugin:

```sh
vagrant plugin install vagrant-proxyconf
```

To configure all possible software on all Vagrant VMs, add the following to _$HOME/.vagrant.d/Vagrantfile_ (or to a project specific _Vagrantfile_):

```ruby
Vagrant.configure("2") do |config|
  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = "http://192.168.0.2:3128/"
    config.proxy.https    = "http://192.168.0.2:3128/"
    config.proxy.no_proxy = "localhost,127.0.0.1,.example.com"
  end
  # ... other stuff
end
```

## Compatibility

This plugin requires Vagrant 1.2 or newer ([downloads](http://www.vagrantup.com/downloads)).

The plugin is supposed to be compatible with all Vagrant providers and other plugins. Please file an [issue](https://github.com/tmatilai/vagrant-proxyconf/issues) if this is not the case. The following providers are confirmed to work:
[AWS](https://github.com/mitchellh/vagrant-aws),
[Digital Ocean](https://github.com/smdahlen/vagrant-digitalocean),
[VirtualBox](http://docs.vagrantup.com/v2/virtualbox),
[VMware Fusion](http://docs.vagrantup.com/v2/vmware/index.html).

For the proxy configuration to take effect for [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus) plugin, version 1.1.1 or newer of it should be used.

## Usage

Install using standard Vagrant plugin installation method: `vagrant plugin install vagrant-proxyconf`. See the [wiki](https://github.com/tmatilai/vagrant-proxyconf/wiki) for instructions to install a pre-release version.

The plugin hooks itself to all Vagrant commands triggering provisioning (e.g. `vagrant up`, `vagrant provision`, etc.). The proxy configurations are written just before provisioners are run.

Proxy settings can be configured in Vagrantfile. In the common case that you want to use the same configuration in all Vagrant machines, you can use _$HOME/.vagrant.d/Vagrantfile_ or environment variables. Platform specific settings are only used on virtual machines that support them (i.e. Apt configuration on Debian based systems), so there is no harm using global configuration.

Project specific Vagrantfile overrides global settings. Environment variables override both.

It is a good practise to wrap plugin specific configuration with `Vagrant.has_plugin?` checks so the user's Vagrantfiles do not break if plugin is uninstalled or Vagrantfile shared with people not having the plugin installed. (For Vagrant 1.2 you have to use `if defined?(VagrantPlugins::ProxyConf)` instead.)

### Default/global configuration

It's a common case that you want all possible connections to pass through the same proxy. This will set the default values for all other proxy configuration keys. It also sets default proxy configuration for all Chef Solo and Chef Client provisioners.

Many programs (wget, curl, yum, etc.) can be configured to use proxies with `http_proxy` or `HTTP_PROXY` etc. environment variables. This configuration will be written to _/etc/profile.d/proxy.sh_ and _/etc/environment_ on the guest.

Also sudo will be configured to preserve the variables. This requires that sudo in the VM is configured to support "sudoers.d", i.e. _/etc/sudoers_ contains line `#includedir /etc/sudoers.d`.

#### Example Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = "http://192.168.0.2:3128/"
    config.proxy.https    = "http://192.168.0.2:3128/"
    config.proxy.no_proxy = "localhost,127.0.0.1,.example.com"
  end
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
* A proxy should be specified in the form of _http://[user:pass@]host:port_.
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

### Disabling the plugin

The plugin can be totally skipped by setting `config.proxy.enabled` to `false` or empty string (`""`). This can be useful to for example disable it for some provider.

#### Example Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  config.proxy.http = "http://192.168.0.2:3128/"

  config.vm.provider :my_cloud do |cloud, override|
    override.proxy.enabled = false
  end
  # ... other stuff
end
```

### Apt

Configures Apt to use the specified proxy settings. The configuration will be written to _/etc/apt/apt.conf.d/01proxy_ on the guest.

#### Example Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  config.apt_proxy.http  = "http://192.168.33.1:3142"
  config.apt_proxy.https = "DIRECT"
  # ... other stuff
end
```

#### Configuration keys

* `config.apt_proxy.http`  - The proxy for HTTP URIs
* `config.apt_proxy.https` - The proxy for HTTPS URIs
* `config.apt_proxy.ftp`   - The proxy for FTP URIs

#### Possible values

* If all keys are unset or `nil`, no configuration is written or modified.
* A proxy can be specified in the form of _http://[user:pass@]host:port_.
* Empty string (`""`) or `false` in any key also force the configuration file to be written, but without configuration for that scheme. Can be used to clear the old configuration and/or override a global setting.
* `"DIRECT"` can be used to specify that no proxy should be used. This is mostly useful for disabling proxy for HTTPS URIs when HTTP proxy is set (as Apt defaults to the latter).
* Please refer to [apt.conf(5)](http://manpages.debian.net/man/5/apt.conf) manual for more information.

#### Environment variables

* `VAGRANT_APT_HTTP_PROXY`
* `VAGRANT_APT_HTTPS_PROXY`
* `VAGRANT_APT_FTP_PROXY`

These also override the Vagrantfile configuration. To disable or remove the proxy use "DIRECT" or an empty value.

For example to spin up a VM, run:

```sh
VAGRANT_APT_HTTP_PROXY="http://proxy.example.com:8080" vagrant up
```

#### Running apt-cacher-ng on a Vagrant box

[apt-cacher-box](https://github.com/tmatilai/apt-cacher-box) gives an example for setting up apt-cacher proxy server in a Vagrant VM.

### Git

Configures Git to use the specified proxy settings.

#### Example Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  config.git_proxy.http  = "http://192.168.33.1:3142"
  # ... other stuff
end
```

#### Configuration keys

* `config.git_proxy.http` - The proxy for Git

#### Possible values

* If the keys is unset or `nil`, the current configuration is not modified.
* A proxy can be specified in the form of _http://[user:pass@]host:port_.
* Empty string (`""`) or `false` disables the proxy from the configuration.

#### Environment variables

* `VAGRANT_GIT_HTTP_PROXY`

This also overrides the Vagrantfile configuration. To disable or remove the proxy use an empty value.

For example to spin up a VM, run:

```sh
VAGRANT_GIT_HTTP_PROXY="http://proxy.example.com:8123" vagrant up
```

### Subversion

Configures Subversion to use the specified proxy settings.

#### Example Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  config.svn_proxy.http  = "http://192.168.33.1:3142"
  # ... other stuff
end
```

#### Configuration keys

* `config.svn_proxy.http` - The proxy for Subversion

#### Possible values

* If the keys is unset or `nil`, the current configuration is not modified.
* A proxy can be specified in the form of _http://[user:pass@]host:port_.
* Empty string (`""`) or `false` disables the proxy from the configuration.

#### Environment variables

* `VAGRANT_SVN_HTTP_PROXY`

This also overrides the Vagrantfile configuration. To disable or remove the proxy use an empty value.

For example to spin up a VM, run:

```sh
VAGRANT_SVN_HTTP_PROXY="http://proxy.example.com:8123" vagrant up
```

### Yum

Configures Yum to use the specified proxy settings. The configuration will be inserted to _/etc/yum.conf_ on the guest.

#### Example Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  config.yum_proxy.http  = "http://192.168.33.1:3142"
  # ... other stuff
end
```

#### Configuration keys

* `config.yum_proxy.http` - The proxy for yum

#### Possible values

* If the keys is unset or `nil`, the current configuration is not modified.
* A proxy can be specified in the form of _http://[user:pass@]host:port_.
* Empty string (`""`) or `false` disables the proxy from the configuration.

#### Environment variables

* `VAGRANT_YUM_HTTP_PROXY`

This also overrides the Vagrantfile configuration. To disable or remove the proxy use an empty value.

For example to spin up a VM, run:

```sh
VAGRANT_YUM_HTTP_PROXY="http://proxy.example.com:8123" vagrant up
```

## Related plugins and projects

* [apt-cacher-box](https://github.com/tmatilai/apt-cacher-box)<br/>
  a Vagrant setup for apt-cacher-ng.
* [polipo-box](https://github.com/tmatilai/polipo-box)<br/>
  a Vagrant setup for [polipo](http://www.pps.univ-paris-diderot.fr/~jch/software/polipo/) caching web proxy.
* [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier)<br/>
  An excellent Vagrant plugin that shares various cache directories among similar VM instances. Should work fine together with vagrant-proxyconf.
