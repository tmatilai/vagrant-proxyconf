# 1.0.2 / _Unreleased_


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
[GH-35]: https://github.com/tmatilai/vagrant-proxyconf/issues/35 "Issue 35"
[GH-36]: https://github.com/tmatilai/vagrant-proxyconf/issues/36 "Issue 36"
