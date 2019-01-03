require 'vagrant'

module VagrantPlugins
  module ProxyConf
    class Plugin < Vagrant.plugin('2')
      config 'apt_proxy' do
        require_relative 'config/apt_proxy'
        Config::AptProxy
      end

      config 'chef_proxy' do
        require_relative 'config/chef_proxy'
        Config::ChefProxy
      end

      config 'docker_proxy' do
        require_relative 'config/docker_proxy'
        Config::DockerProxy
      end

      config 'env_proxy' do
        require_relative 'config/env_proxy'
        Config::EnvProxy
      end

      config 'git_proxy' do
        require_relative 'config/git_proxy'
        Config::GitProxy
      end

      config 'npm_proxy' do
        require_relative 'config/npm_proxy'
        Config::NpmProxy
      end

      config 'pear_proxy' do
        require_relative 'config/pear_proxy'
        Config::PearProxy
      end

      config 'proxy' do
        require_relative 'config/proxy'
        Config::Proxy
      end

      config 'svn_proxy' do
        require_relative 'config/svn_proxy'
        Config::SvnProxy
      end

      config 'yum_proxy' do
        require_relative 'config/yum_proxy'
        Config::YumProxy
      end
    end
  end
end
