# Vagrant Proxy Configuration Plugin

A [Vagrant](http://www.vagrantup.com/) 1.1+ plugin that configures the virtual machine to use specified proxies for package managers etc.

At this state we support:

- [APT](http://en.wikipedia.org/wiki/Advanced_Packaging_Tool) proxy/cacher.

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

## Related plugins and projects

- [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier)
- [vagrant-proxy](https://github.com/clintoncwolfe/vagrant-proxy)
