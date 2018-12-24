require 'vagrant'
require_relative 'key_mixin'

module VagrantPlugins
  module ProxyConf
    module Config
      # Proxy configuration for pear
      #
      # @!parse class PearProxy < Vagrant::Plugin::V2::Config; end
      class PearProxy < Vagrant.plugin('2', :config)
        include KeyMixin
        # @!parse extend KeyMixin::ClassMethods

        # @return [String] the HTTP proxy
        key :http, env_var: 'VAGRANT_PEAR_HTTP_PROXY'
      end
    end
  end
end
