require 'vagrant'

module VagrantPlugins
  module ProxyConf
    class Plugin < Vagrant.plugin('2')
      config 'apt_proxy' do
        require_relative 'config/apt_proxy'
        Config::AptProxy
      end

      config 'env_proxy' do
        require_relative 'config/env_proxy'
        Config::EnvProxy
      end

      config 'git_proxy' do
        require_relative 'config/git_proxy'
        Config::GitProxy
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

      config 'win_proxy' do
        require_relative 'config/win_proxy'
        Config::WinProxy
      end

    end
  end
end
