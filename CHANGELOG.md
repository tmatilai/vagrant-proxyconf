# 0.4.1 / _Unreleased_


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
