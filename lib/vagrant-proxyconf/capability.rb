require 'vagrant'

module VagrantPlugins
  module ProxyConf
    class Plugin < Vagrant.plugin('2')
      guest_capability 'debian', 'apt_proxy_conf' do
        require_relative 'cap/debian/apt_proxy_conf'
        Cap::Debian::AptProxyConf
      end

      guest_capability 'linux', 'env_proxy_conf' do
        require_relative 'cap/linux/env_proxy_conf'
        Cap::Linux::EnvProxyConf
      end

      guest_capability 'linux', 'git_proxy_conf' do
        require_relative 'cap/linux/git_proxy_conf'
        Cap::Linux::GitProxyConf
      end

      guest_capability 'linux', 'npm_proxy_conf' do
        require_relative 'cap/linux/npm_proxy_conf'
        Cap::Linux::NpmProxyConf
      end

      guest_capability 'linux', 'pear_proxy_conf' do
        require_relative 'cap/linux/pear_proxy_conf'
        Cap::Linux::PearProxyConf
      end

      guest_capability 'linux', 'svn_proxy_conf' do
        require_relative 'cap/linux/svn_proxy_conf'
        Cap::Linux::SvnProxyConf
      end

      guest_capability 'redhat', 'yum_proxy_conf' do
        require_relative 'cap/redhat/yum_proxy_conf'
        Cap::Redhat::YumProxyConf
      end
    end
  end
end
