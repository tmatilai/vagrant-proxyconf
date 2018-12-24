require 'vagrant'
require_relative 'key_mixin'

module VagrantPlugins
  module ProxyConf
    module Config
      # Configuration for generic `<protocol>_proxy` environment variables
      #
      # @!parse class ChefProxy < Vagrant::Plugin::V2::Config; end
      class ChefProxy < Vagrant.plugin('2', :config)
        include KeyMixin
        # @!parse extend KeyMixin::ClassMethods

        # @return [String] the HTTP proxy
        key :http, env_var: 'VAGRANT_CHEF_HTTP_PROXY'

        # @return [String] the HTTPS proxy
        key :https, env_var: 'VAGRANT_CHEF_HTTPS_PROXY'

        # @return [String] a comma separated list of hosts or domains which do not use proxies
        key :no_proxy, env_var: 'VAGRANT_CHEF_NO_PROXY'
      end
    end
  end
end
