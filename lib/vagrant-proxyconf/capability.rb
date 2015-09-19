require 'vagrant'

module VagrantPlugins
  module ProxyConf
    class Plugin < Vagrant.plugin('2')
      guest_capability 'debian', 'apt_proxy_conf' do
        require_relative 'cap/debian/apt_proxy_conf'
        Cap::Debian::AptProxyConf
      end

      guest_capability 'linux', 'docker_proxy_conf' do
        require_relative 'cap/linux/docker_proxy_conf'
        Cap::Linux::DockerProxyConf
      end

      guest_capability 'coreos', 'docker_proxy_conf' do
        require_relative 'cap/coreos/docker_proxy_conf'
        Cap::CoreOS::DockerProxyConf
      end

      guest_capability 'debian', 'docker_proxy_conf' do
        require_relative 'cap/debian/docker_proxy_conf'
        Cap::Debian::DockerProxyConf
      end

      guest_capability 'linux', 'env_proxy_conf' do
        require_relative 'cap/linux/env_proxy_conf'
        Cap::Linux::EnvProxyConf
      end

      guest_capability 'windows', 'env_proxy_conf' do
        require_relative 'cap/windows/env_proxy_conf'
        Cap::Windows::EnvProxyConf
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
