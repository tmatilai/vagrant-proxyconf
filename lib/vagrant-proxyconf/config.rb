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

      config 'proxy' do
        require_relative 'config/proxy'
        Config::Proxy
      end

      config 'yum_proxy' do
        require_relative 'config/yum_proxy'
        Config::YumProxy
      end
    end
  end
end
