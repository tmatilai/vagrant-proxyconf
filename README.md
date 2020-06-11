# Proxy Configuration Plugin for Vagrant

<span class="badges">

[![Gem Version](https://badge.fury.io/rb/vagrant-proxyconf.png)](https://rubygems.org/gems/vagrant-proxyconf)
[![Build Status](https://travis-ci.org/tmatilai/vagrant-proxyconf.svg?branch=master)](https://travis-ci.org/tmatilai/vagrant-proxyconf)

</span>

A [Vagrant](http://www.vagrantup.com/) plugin that configures the virtual machine to use specified proxies. This is useful for example in case you are behind a corporate proxy server, or you have a caching proxy (for example [polipo](https://github.com/tmatilai/polipo-box)).

The plugin can set:

* generic `http_proxy` etc. environment variables that many programs support
* default proxy configuration for all Chef provisioners
* proxy configuration for Apt
* proxy configuration for Docker
* proxy configuration for Git
* proxy configuration for npm
* proxy configuration for PEAR
* proxy configuration for Subversion
* proxy configuration for Yum
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

New Behavior Warning: Setting the plugin to disabled now unconfigures all or specific proxies.

The plugin can be disabled by setting `config.proxy.enabled` to `false` or empty string (`""`).
This can be also be used to disable a proxy for some provider.
Specific applications can be disabled by setting `config.proxy.enabled` to
a hash( like `{ svn: false }` or `{ svn: {enabled: false} }`).

```ruby
config.proxy.enabled         # => all applications enabled(default)
config.proxy.enabled = true  # => all applications enabled
config.proxy.enabled = { svn: false, docker: false }
                             # => specific applications disabled
config.proxy.enabled = ""    # => all applications disabled
config.proxy.enabled = false # => all applications disabled
```

### Skipping the plugin

The plugin can also be skipped from applying/removing the proxy configuration for a specific provider.

#### When the plugin is disabled as in the following example:

```
{
  :apt => {
    :enabled => false,
    :skip    => true,
  },
  :svn => {
    :enabled => false,
    :skip    => true,
  },
}
```

The plugin is disabled, but `skip = true` means that no proxy configuration will be removed so the system
will remain in it's most recent state. This can be useful if you just want to skip over specific provider
being configured or unconfigured.


#### When the plugin is enabled as in the following example:

```
{
  :apt => {
    :enabled => true,
    :skip    => false,
  },
  :svn => {
    :enabled => true,
    :skip    => true,
  },
}
```

The plugin is enabled, but `skip = true` means that no proxy configuration will be applied so the system
will remain in it's most recent state. This can be useful if you just want to skip over specific provider
being configured or unconfigured.

In the example above the `apt` proxy will be enabled and proxy configuration will be applied, but the
`svn` proxy even though it's enabled will be skipped.


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

### Configuration for applications
Configures applications to use proxy settings. The configurations will be written to
configuration files for each application.

#### Configurable applications
Following applications can be configured.
Configurations are based on default configuration(`config.proxy.*`) and
can be overridden except SVN.
SVN configuration is not set if no SVN specific configuration.

|  Application           | Base conf.     | Specific conf.      | Env. var.     |
| -----------------------|----------------|---------------------|---------------|
| configure_apt_proxy    | config.proxy.* | config.apt_proxy.*  | VAGRANT_APT_* |
| configure_git_proxy    | N/A            | config.git_proxy.*  | VAGRANT_GIT_* |
| configure_svn_proxy    | N/A            | config.svn_proxy.*  | VAGRANT_SVN_* |
| configure_yum_proxy    | config.proxy.* | config.yum_proxy.*  | VAGRANT_YUM_* |

#### Example Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  config.proxy.http     = "http://192.168.0.2:3128/"
  config.proxy.https    = "http://192.168.0.2:3128/"
  config.proxy.no_proxy = "localhost,127.0.0.1,.example.com"
  config.apt_proxy.http = "http://192.168.33.1:3142"
  config.apt_proxy.https = "DIRECT"
  # ... other stuff
end
```
#### Environment variables
These also override the Vagrantfile configuration. To disable or remove the proxy use "DIRECT" or an empty value.

For example to spin up a VM and set the APT proxy to `http://proxy.example.com:8080, run:

```sh
VAGRANT_APT_HTTP_PROXY="http://proxy.example.com:8080" vagrant up
```

|  Provider | Environment Variable         | Descrption                    | Precendence |
|-----------|------------------------------|-------------------------------|-------------|
| apt       | `VAGRANT_APT_HTTP_PROXY`     | Configures APT http proxy     | Highest     |
|           | `VAGRANT_APT_HTTPS_PROXY`    | Configures APT https proxy    | Highest     |
|           | `VAGRANT_APT_FTP_PROXY`      | Configures APT ftp proxy      | Highest     |
|           | `VAGRANT_APT_VERIFY_PEER`    | Configures APT Verify-Peer    | Highest     |
|           | `VAGRANT_APT_VERIFY_HOST`    | Configures APT Verify-Host    | Highest     |
| chef      | `VAGRANT_CHEF_HTTP_PROXY`    | Configures CHEF http proxy    | Highest     |
|           | `VAGRANT_CHEF_HTTPS_PROXY`   | Configures CHEF https proxy   | Highest     |
|           | `VAGRANT_CHEF_NO_PROXY`      | Configures CHEF no proxy      | Highest     |
| docker    | `VAGRANT_DOCKER_HTTP_PROXY`  | Configuers DOCKER http proxy  | Highest     |
|           | `VAGRANT_DOCKER_HTTPS_PROXY` | Configures DOCKER https proxy | Highest     |
|           | `VAGRANT_DOCKER_NO_PROXY`    | Configures DOCKER no proxy    | Highest     |
| env       | `VAGRANT_ENV_HTTP_PROXY`     | Configures ENV http proxy     | Highest     |
|           | `VAGRANT_ENV_HTTPS_PROXY`    | Configures ENV https proxy    | Highest     |
|           | `VAGRANT_ENV_FTP_PROXY`      | Configures ENV FTP proxy      | Highest     |
|           | `VAGRANT_ENV_NO_PROXY`       | Configures ENV no proxy       | Highest     |
| git       | `VAGRANT_GIT_HTTP_PROXY`     | Configures GIT http proxy     | Highest     |
|           | `VAGRANT_GIT_HTTPS_PROXY`    | Configures GIT https proxy    | Highest     |
| npm       | `VAGRANT_NPM_HTTP_PROXY`     | Configures NPM http proxy     | Highest     |
|           | `VAGRANT_NPM_HTTPS_PROXY`    | Configures NPM https proxy    | Highest     |
|           | `VAGRANT_NPM_NO_PROXY`       | Configures NPM no proxy       | Highest     |
| pear      | `VAGRANT_PEAR_HTTP_PROXY`    | Configures PEAR http proxy    | Highest     |
| svn       | `VAGRANT_SVN_HTTP_PROXY`     | Configures SVN http proxy     | Highest     |
|           | `VAGRANT_SVN_NO_PROXY`       | Configures SVN no proxy       | Highest     |
| yum       | `VAGRANT_YUM_HTTP_PROXY`     | Configures YUM http proxy     | Highest     |

## Related plugins and projects

* [apt-cacher-box](https://github.com/tmatilai/apt-cacher-box)<br/>
  a Vagrant setup for apt-cacher-ng.
* [polipo-box](https://github.com/tmatilai/polipo-box)<br/>
  a Vagrant setup for [polipo](http://www.pps.univ-paris-diderot.fr/~jch/software/polipo/) caching web proxy.
* [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier)<br/>
  An excellent Vagrant plugin that shares various cache directories among similar VM instances. Should work fine together with vagrant-proxyconf.


## Installing a pre-release version

* A [released](https://rubygems.org/gems/vagrant-proxyconf) pre-release version:

  ```
  vagrant plugin install --plugin-source https://rubygems.org/ --plugin-prerelease vagrant-proxyconf
  ```

* Development version from git repository:

  ```
  git clone https://github.com/tmatilai/vagrant-proxyconf.git
  cd vagrant-proxyconf

  # Optionally check out other than the master branch
  git checkout <branch>

  # If you don't have Ruby installed, you can use <path/to/vagrant>/embedded/bin/gem>.
  # If you have Docker you can use the Ruby image:
  # docker run -it --rm -v ${PWD}:/usr/src/myapp -w /usr/src/myapp ruby:2.6 gem build vagrant-proxyconf.gemspec
  gem build vagrant-proxyconf.gemspec

  vagrant plugin install vagrant-proxyconf-*.gem
  ```

  Paths to Vagrant's embedded gem:
  * Linux: `/opt/vagrant/embedded/bin/gem`
  * OS X: `/Applications/Vagrant/embedded/bin/gem`


## Development Known Issues


### When running `bundle exec vagrant status` I get `Encoded files can't be read outside of the Vagrant installer.`

```
$ bundle exec vagrant status
Vagrant failed to initialize at a very early stage:

The plugins failed to load properly. The error message given is
shown below.

Encoded files can't be read outside of the Vagrant installer.
```

The solution is to add this to the Gemfile

```
embedded_locations = %w(/Applications/Vagrant/embedded /opt/vagrant/embedded)

embedded_locations.each do |p|
    ENV['VAGRANT_INSTALLER_EMBEDDED_DIR'] = p if File.directory?(p)
end

unless ENV.key?('VAGRANT_INSTALLER_EMBEDDED_DIR')
    $stderr.puts "Couldn't find a packaged install of vagrant, and we need this"
    $stderr.puts 'in order to make use of the RubyEncoder libraries.'
    $stderr.puts 'I looked in:'
    embedded_locations.each do |p|
        $stderr.puts "  #{p}"
    end
end
```

# Contributors

* @tmatilai
* @otahi
* @jperville
* @johnbellone
* @SaschaGuenther
* @mrsheepuk
* @vboerchers
* @rlaveycal
* @pomeh
* @mynamewastaken
* @lawsonj2019
* @jonekdahl
* @hexmode
* @craigmunro
* @greut
* @chucknelson
* @codylane
