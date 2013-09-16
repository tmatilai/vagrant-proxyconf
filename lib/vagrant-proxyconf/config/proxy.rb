require 'uri'
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

        # @return [String] the HTTP proxy
        key :http, env_var: 'VAGRANT_HTTP_PROXY'

        # @return [String] the HTTPS proxy
        key :https, env_var: 'VAGRANT_HTTPS_PROXY'

        # @return [String] the FTP proxy
        key :ftp, env_var: 'VAGRANT_FTP_PROXY'

        # @return [String] a comma separated list of hosts or domains which do not use proxies
        key :no_proxy, env_var: 'VAGRANT_NO_PROXY'

        # @return [String] username for the HTTP proxy
        def http_user
          user(http)
        end

        # @return [String] password for the HTTP proxy
        def http_pass
          pass(http)
        end

        # @return [String] username for the HTTPS proxy
        def https_user
          user(https)
        end

        # @return [String] password for the HTTPS proxy
        def https_pass
          pass(https)
        end

        private

        def user(uri)
          URI.parse(uri).user if uri
        end

        def pass(uri)
          URI.parse(uri).password if uri
        end
      end
    end
  end
end
