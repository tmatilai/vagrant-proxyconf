require 'vagrant'
require_relative 'key_mixin'

module VagrantPlugins
  module ProxyConf
    module Config
      # Default configuration for all proxy Config classes
      #
      # @!parse class Proxy < Vagrant::Plugin::V2::Config; end
      class Proxy < Vagrant.plugin('2', :config)
        include KeyMixin
        # @!parse extend KeyMixin::ClassMethods

        # Defines the mode of the plugin
        key :enabled, env_var: 'VAGRANT_PROXY'

        # @return [String] the HTTP proxy
        key :http, env_var: 'VAGRANT_HTTP_PROXY'

        # @return [String] the HTTPS proxy
        key :https, env_var: 'VAGRANT_HTTPS_PROXY'

        # @return [String] the FTP proxy
        key :ftp, env_var: 'VAGRANT_FTP_PROXY'

        # @return [String] a comma separated list of hosts or domains which do not use proxies
        key :no_proxy, env_var: 'VAGRANT_NO_PROXY'

        # @return [String] the AutoConfigURL
        key :autoconfig, env_var: 'VAGRANT_ENV_AUTO_CONFIG_URL'
      end
    end
  end
end
