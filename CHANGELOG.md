# 2.0.10 / Not yet released

# 2.0.9 / 2020-07-02

This is a bug fix release when provisioning docker hosts inside of
vagrant. This version removes the hard coded DOCKER_CONFIG environment
variable in /etc/environment and hard codes the client config to
/home/vagrant/.docker/config.json. This is a temporary work around until
the this can be refactored.

Existing values in /home/vagrant/.docker/config.json should be preserved
and merged when the vagrant-proxy conf is being provisioned.

#### Closed Issues

- https://github.com/tmatilai/vagrant-proxyconf/issues/218


# 2.0.8 / 2020-06-10

This is a bug fix release for windows users which fixes a bug with the
tempfile creation when uploading and downloading files from the vagrant
machine.



#### Closed Issues

- [tempfile implementation on windows doesn't always seem to work
  #220](https://github.com/tmatilai/vagrant-proxyconf/issues/220)

#### Credits

Big thanks to @chucknelson for debugging and troubleshooting and getting
to the bottom of this for windows users. Thank you!

- @chucknelson

# 2.0.7 / 2019-11-14

This is a bug fix release.

- Addresses issues with docker proxy configuration and permissions.

#### Closed Issues

- https://github.com/tmatilai/vagrant-proxyconf/milestone/3


#### Credits

Thank you to these folks how identified the bugs and provided
workarounds.

- @antoinetran
- @tkang007


# 2.0.6 / 2019-08-09

This is a bug fix release addressing a permissions problem with the docker proxy client config.
The fixes the permissions problem setting /etc/docker/config.json from 0600 to 0644 permissions.

#### Credits

- Credit to this release goes to @takuto-h.

# 2.0.5 / 2019-07-27

#### Deprecations:

- Dropped support for vagrant 1.9.8 due to our tests failinging and it's more than 2 years old.

#### Credits

- Credit to this release goes to @greut. Thank you for your detailed information and for reporting a solution.

This is a feature enhancement for the APT proxy configuration when using
a proxy that is terminating SSL.  By default, these settings are left
as-is and only enabled when a user wants to configure these settings.
This feature supports enabling/disabling the follwoing settings

#### file `/etc/apt/apt.conf.d/01proxy`

```
Acquire::https::Verify-Host
Acquire::https::Verify-Peer
```

#### Configuration settings for `Acquire::https::Verify-Host` and `Acquire::https::Verify-Peer`

  * The value for these settings must be a string.
  * When `"true"` enable the setting
  * When `"false"` disable the setting
  * When `""` this setting is removed.

#### Example Inside the Vagrantfile

```
Vagrant.configure("2") do |config|

  config.vm.define 'apt_host' do |c|
    c.vm.box = "bento/ubuntu-18.04"

    if Vagrant.has_plugin?('vagrant-proxyconf')
      c.proxy.http     = ENV['HTTP_PROXY']
      c.proxy.https    = ENV['HTTPS_PROXY']
      c.proxy.no_proxy = ENV['NO_PROXY']
      c.apt_proxy.verify_host = "false"
      c.apt_proxy.verify_peer = "false"

      c.proxy.enabled = {
        :apt => {
          :enabled => true,
          :skip    => false,
        },
        :env => {
          :enabled => true,
          :skip    => false,
        },
        :git => {
          :enabled => true,
          :skip    => false,
        }
      }
    end
  end

end
```

#### Example setting the environment variables

```
export VAGRANT_APT_VERIFY_HOST="false"
export VAGRANT_APT_VERIFY_PEER="false"
vagrant up
vagrant provision
```

**NOTE** If you change a setting in your `Vagrantfile` and the box is
running, you can run `vagrant provision` or `vagrant reload` to adjust
the settings.

Supporting Issues:
  - https://github.com/tmatilai/vagrant-proxyconf/issues/199

Supporting Integration Tests:
  - Look at the examples in directory [199](test/issues/199/)


# 2.0.4 / 2019-07-24

This is a bug fix release to address a logic issue for supporting docker
versions when attempting to configure a docker proxy.


Bug Fixes:
  - https://github.com/tmatilai/vagrant-proxyconf/issues/197

# 2.0.3 / 2019-07-23

This is a bug fix release to address systemd and docker issues.

Bug Fixes:
  - https://github.com/tmatilai/vagrant-proxyconf/issues/172

# 2.0.2 / 2019-07-19

This is a bug fix release, please see the issues below for furthe
details.  This fix should address some Docker proxy problems when using
systemd.

Bug Fixes:
  - https://github.com/tmatilai/vagrant-proxyconf/issues/172

# 2.0.1 / 2019-03-31

Improvements:

  - Check for existence of HTTP_PROXY and HTTPS_PROXY environment variables.
    If neither are set this plugin is automatically disabled.
  - Correctly uses the Tempfile pattern now via commit. 8ee2a2bb146aeb9fb1b27c80814e9000eff34aa1

Bug fixes:
  - Docker proxy conf not set the first time the provisioner is used (trusty64) - #155
  - Proxy doesn't work for Docker with systemd - #172
  - Provisioning of docker fails - #180
  - Docker provider: Guest-specific operations were attempted on a machine that is not ready for guest communication. - #181
  - Provisioning of docker fails issue 180. - #182
  - vagrant-proxyconf running on Win10 and provisioning with Docker. - #186
  - Cannot force to write but without configuration. - #188

# 2.0.0 / 2019-01-03

Improvements:

  - Significant refactor to support disabling a proxy. Now when `config.proxy.enabled = false` all supporting proxies will be uncofigured.
  - Added new tests for new features.
  - Updated README.md to reflect new behavior.
  - Cleaned up travis builds to support newere versions of vagrant.

Features:
  - Added new configuration parameter for `skipping` configuring a disabled or enabled proxy.

Bug Fixes:

  - Disable proxy settings in provisioned box ([GH-167][])
  - unable to disable proxy for chef provisioners ([GH-118][])
  - Proxy remains enabled after updating config ([GH-87][])


# 1.5.2 / 2015-10-01

Improvements:

  - Support URI-encorded UserInfo for Chef, SVN, Yum ([GH-130][])
  - Support docker on Debian/Ubuntu with systemd ([GH-133][])

# 1.5.1 / 2015-07-25

Bug fixes:

  - Fix docker configuration ([GH-106][])

# 1.5.0 / 2015-01-15

Features:

  - Ignore specific applications by passing a hash to `config.proxy.enabled` ([GH-93][])
  - Support the `chef_zero` provisioner in Vagrant 1.7+ ([GH-105][])

Improvements:

  - Add -f option for mv and rm commands to overrides any -i or -n options in shell aliases ([GH-90][])
  - Use system-wide configuration for NPM ([GH-91][])
  - Avoid restarting docker when configuration doesn't change ([GH-92][])
  - Fix Chef provisioner detection compatibility with Vagrant 1.7+ ([GH-103][])

Bug fixes:

  - Don't error if removing non-existing git proxy configuration ([GH-94][])

# 1.4.0 / 2014-09-28

Features:

  - Support for configuring Docker ([GH-69][])

# 1.3.2 / 2014-05-30

Improvements:

  - Ensure that the .npmrc file exists to work around [NPM-5065](https://github.com/npm/npm/issues/5065)

Bug fixes:

  - Fix /etc/environment for empty end `false` values

# 1.3.1 / 2014-05-09

Improvements:

  - Write environment variable configuration also to /etc/environment on Linux ([GH-58][], [GH-67][])
    * Fixes compatibility with vagrant-omnibus and non-login shells

# 1.3.0 / 2014-05-02

Features:

  - Support setting proxy environment variables on Windows guests ([GH-63][])
  - Support setting proxy environment variables on CoreOS guests ([GH-62][])
    * Requires CoreOS 286.0 or later

Bug fixes:

  - Fix https proxy configuration for npm if different to http ([GH-57][])
  - Use absolute paths to `git`, `npm`, and `pear` commands when configuring them using sudo to avoid PATH problems ([GH-59][], [GH-60][])

# 1.2.0 / 2014-03-02

Deprecations:

  - Deprecate `config.env_proxy` and `VAGRANT_ENV_*_PROXY`, as `config.proxy.*` and `VAGRANT_*_PROXY` should be enough. The env_proxy config options will be removed in v2.0.0.
  - `config.apt_proxy.*` and `VAGRANT_APT_*_PROXY` URIs should explicitly set the scheme and port. In v2.0.0 the scheme will be required, and default port will be scheme's default (currently 3142).

Features:

  - Support for configuring git and svn ([GH-40][], [GH-49][])
  - Support for configuring npm ([GH-50][], [GH-51][])

# 1.1.0 / 2014-02-06

Features:

  - Add `config.proxy.enabled` option which can be set to `false` to disable the plugin ([GH-39][])
  - Support for configuring PEAR ([GH-34][])

Improvements:

  - Compatibility with Vagrant v1.5:
    * `Vagrant.require_plugin` deprecated ([GH-44][])
    * Hook before `SyncedFolders` action as it can install NFS client ([GH-45][])
    * Vagrant 1.5.0 is not released at the time of this release, so compatibility can't be guaranteed yet
  - Run Travis tests against all supported Vagrant minor versions with correct Ruby version
  - Decrease noise level, don't print messages when configuring something

Bug fixes:

  - Quote `no_proxy` in _/etc/profile.d/proxy.sh_ to protect it from spaces ([GH-42][])

# 1.0.1 / 2013-12-01

- Ensure that Yum configuration includes the (default) port ([GH-36][])

# 1.0.0 / 2013-11-05

- Add support for configuring Yum directly (not only via global env vars) ([GH-4][])
- Remove the target path before uploading files to VM to avoid permission problems ([GH-32][])
- Disable environment variable setting on CoreOS ([GH-35][])

# 0.6.0 / 2013-10-15

- Add support for the [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) plugin ([GH-30][])

# 0.5.3 / 2013-09-30

- Compatibility with vagrant-aws v0.4.0 ([GH-28][])
    * Next vagrant-aws release [will remove](https://github.com/mitchellh/vagrant-aws/commit/dd17f23) its custom TimedProvision action class
- Ensure that generated configuration files are not deleted before uploading ([GH-29][])

# 0.5.2 / 2013-09-27

- Fix sudo configuration on old Ubuntu 10.04 "lucid" guests ([GH-26][])
    * Ubuntu bug [\#553786](https://bugs.launchpad.net/ubuntu/+source/sudo/+bug/553786)
- Always set correct permissions on generated configuration files ([GH-27][], [GH-26][])

# 0.5.1 / 2013-09-17

- Configure sudo to preserve the `*_proxy` environment variables ([GH-23][], [GH-25][])
    * Requires that sudo in VM is configured to support "sudoers.d", i.e. _/etc/sudoers_ contains line `#includedir /etc/sudoers.d`
- Fix Chef provisioner configuration if a proxy is set to `false` ([GH-24][])
- Create the directories for configuration files if they don't exist ([GH-25][])

# 0.5.0 / 2013-09-11

- Set default proxy configuration for all Chef provisioners ([GH-19][], [GH-21][])

# 0.4.0 / 2013-09-04

- BREAKING: Environment variables for Apt config renamed to `VAGRANT_APT_HTTP_PROXY` etc. ([GH-15][])
- Configure all supported programs with a single `config.proxy` configuration or `VAGRANT_HTTP_PROXY` etc. environment variables ([GH-14][], [GH-17][])
- Add support for global `*_proxy` environment variables via `config.env_proxy` ([GH-6][])
- Configure the VM also on `vagrant provision` ([GH-12][])
    * Hook to all commands that trigger provisioning action
- Ensure the proxies are configured before [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus) ([GH-13][])
    * Requires vagrant-omnibus v1.1.1 or newer to work correctly

# 0.3.0 / 2013-07-12

- Support the [AWS provider](https://github.com/mitchellh/vagrant-aws) ([GH-10][])
- Support `vagrant rebuild` command of the [Digital Ocean provider](https://github.com/smdahlen/vagrant-digitalocean) ([GH-11][])
- Do not add the default port to complete URIs (e.g. `http://proxy`) ([GH-9][])

# 0.2.0 / 2013-07-05

- Add Apt proxy configuration for FTP URIs ([GH-5][])
- Warn and fail if Vagrant is older than v1.2.0 ([GH-7][])
- New [home page](http://tmatilai.github.io/vagrant-proxyconf/) ([GH-8][])

# 0.1.1 / 2013-06-27

- Don't crash if there is no configuration for us in the Vagrantfiles ([GH-2][])
    * Related [Vagrant issue](https://github.com/mitchellh/vagrant/issues/1877)

# 0.1.0 / 2013-06-27

- Initial release
- Support for Apt proxy configuration
- Based heavily on [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier) plugin


[GH-2]:  https://github.com/tmatilai/vagrant-proxyconf/issues/2  "Issue 2"
[GH-4]:  https://github.com/tmatilai/vagrant-proxyconf/issues/4  "Issue 4"
[GH-5]:  https://github.com/tmatilai/vagrant-proxyconf/issues/5  "Issue 5"
[GH-6]:  https://github.com/tmatilai/vagrant-proxyconf/issues/6  "Issue 6"
[GH-7]:  https://github.com/tmatilai/vagrant-proxyconf/issues/7  "Issue 7"
[GH-8]:  https://github.com/tmatilai/vagrant-proxyconf/issues/8  "Issue 8"
[GH-9]:  https://github.com/tmatilai/vagrant-proxyconf/issues/9  "Issue 9"
[GH-10]: https://github.com/tmatilai/vagrant-proxyconf/issues/10 "Issue 10"
[GH-11]: https://github.com/tmatilai/vagrant-proxyconf/issues/11 "Issue 11"
[GH-12]: https://github.com/tmatilai/vagrant-proxyconf/issues/12 "Issue 12"
[GH-13]: https://github.com/tmatilai/vagrant-proxyconf/issues/13 "Issue 13"
[GH-14]: https://github.com/tmatilai/vagrant-proxyconf/issues/14 "Issue 14"
[GH-15]: https://github.com/tmatilai/vagrant-proxyconf/issues/15 "Issue 15"
[GH-17]: https://github.com/tmatilai/vagrant-proxyconf/issues/17 "Issue 17"
[GH-19]: https://github.com/tmatilai/vagrant-proxyconf/issues/19 "Issue 19"
[GH-21]: https://github.com/tmatilai/vagrant-proxyconf/issues/21 "Issue 21"
[GH-23]: https://github.com/tmatilai/vagrant-proxyconf/issues/23 "Issue 23"
[GH-24]: https://github.com/tmatilai/vagrant-proxyconf/issues/24 "Issue 24"
[GH-25]: https://github.com/tmatilai/vagrant-proxyconf/issues/25 "Issue 25"
[GH-26]: https://github.com/tmatilai/vagrant-proxyconf/issues/26 "Issue 26"
[GH-27]: https://github.com/tmatilai/vagrant-proxyconf/issues/27 "Issue 27"
[GH-28]: https://github.com/tmatilai/vagrant-proxyconf/issues/28 "Issue 28"
[GH-29]: https://github.com/tmatilai/vagrant-proxyconf/issues/29 "Issue 29"
[GH-30]: https://github.com/tmatilai/vagrant-proxyconf/issues/30 "Issue 30"
[GH-32]: https://github.com/tmatilai/vagrant-proxyconf/issues/32 "Issue 32"
[GH-34]: https://github.com/tmatilai/vagrant-proxyconf/issues/34 "Issue 34"
[GH-35]: https://github.com/tmatilai/vagrant-proxyconf/issues/35 "Issue 35"
[GH-36]: https://github.com/tmatilai/vagrant-proxyconf/issues/36 "Issue 36"
[GH-39]: https://github.com/tmatilai/vagrant-proxyconf/issues/39 "Issue 39"
[GH-40]: https://github.com/tmatilai/vagrant-proxyconf/issues/40 "Issue 40"
[GH-42]: https://github.com/tmatilai/vagrant-proxyconf/issues/42 "Issue 42"
[GH-44]: https://github.com/tmatilai/vagrant-proxyconf/issues/44 "Issue 44"
[GH-45]: https://github.com/tmatilai/vagrant-proxyconf/issues/45 "Issue 45"
[GH-49]: https://github.com/tmatilai/vagrant-proxyconf/issues/49 "Issue 49"
[GH-50]: https://github.com/tmatilai/vagrant-proxyconf/issues/50 "Issue 50"
[GH-51]: https://github.com/tmatilai/vagrant-proxyconf/issues/51 "Issue 51"
[GH-57]: https://github.com/tmatilai/vagrant-proxyconf/issues/57 "Issue 57"
[GH-58]: https://github.com/tmatilai/vagrant-proxyconf/issues/58 "Issue 58"
[GH-59]: https://github.com/tmatilai/vagrant-proxyconf/issues/59 "Issue 59"
[GH-60]: https://github.com/tmatilai/vagrant-proxyconf/issues/60 "Issue 60"
[GH-62]: https://github.com/tmatilai/vagrant-proxyconf/issues/62 "Issue 62"
[GH-63]: https://github.com/tmatilai/vagrant-proxyconf/issues/63 "Issue 63"
[GH-67]: https://github.com/tmatilai/vagrant-proxyconf/issues/67 "Issue 67"
[GH-69]: https://github.com/tmatilai/vagrant-proxyconf/issues/69 "Issue 69"
[GH-90]: https://github.com/tmatilai/vagrant-proxyconf/issues/90 "Issue 90"
[GH-91]: https://github.com/tmatilai/vagrant-proxyconf/issues/91 "Issue 91"
[GH-92]: https://github.com/tmatilai/vagrant-proxyconf/issues/92 "Issue 92"
[GH-93]: https://github.com/tmatilai/vagrant-proxyconf/issues/93 "Issue 93"
[GH-94]: https://github.com/tmatilai/vagrant-proxyconf/issues/94 "Issue 94"
[GH-103]: https://github.com/tmatilai/vagrant-proxyconf/issues/103 "Issue 103"
[GH-105]: https://github.com/tmatilai/vagrant-proxyconf/issues/105 "Issue 105"
[GH-106]: https://github.com/tmatilai/vagrant-proxyconf/issues/106 "Issue 106"
[GH-130]: https://github.com/tmatilai/vagrant-proxyconf/issues/106 "Issue 130"
[GH-133]: https://github.com/tmatilai/vagrant-proxyconf/issues/106 "Issue 133"
