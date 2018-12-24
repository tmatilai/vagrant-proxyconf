require 'vagrant'
require_relative 'key_mixin'

module VagrantPlugins
  module ProxyConf
    module Config
      # Proxy configuration for npm
      #
      # @!parse class NpmProxy < Vagrant::Plugin::V2::Config; end
      class NpmProxy < Vagrant.plugin('2', :config)
        include KeyMixin
        # @!parse extend KeyMixin::ClassMethods

        # @return [String] the HTTP proxy
        key :http, env_var: 'VAGRANT_NPM_HTTP_PROXY'

        # @return [String] the HTTPS proxy
        key :https, env_var: 'VAGRANT_NPM_HTTPS_PROXY'

        # @return [String] the HTTPS proxy
        key :no_proxy, env_var: 'VAGRANT_NPM_NO_PROXY'
      end
    end
  end
end
