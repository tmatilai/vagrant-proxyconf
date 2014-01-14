require 'vagrant'
require_relative 'key_mixin'

module VagrantPlugins
  module ProxyConf
    module Config
      # Proxy configuration for Subversion
      #
      # @!parse class SvnProxy < Vagrant::Plugin::V2::Config; end
      class SvnProxy < Vagrant.plugin('2', :config)
        include KeyMixin
        # @!parse extend KeyMixin::ClassMethods

        # @return [String] the HTTP proxy
        key :http, env_var: 'VAGRANT_SVN_HTTP_PROXY'
      end
    end
  end
end
