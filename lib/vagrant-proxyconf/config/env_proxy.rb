require 'vagrant'
require_relative 'key_mixin'

module VagrantPlugins
  module ProxyConf
    module Config
      # Configuration for generic `<protocol>_proxy` environment variables
      #
      # @!parse class EnvProxy < Vagrant::Plugin::V2::Config; end
      class EnvProxy < Vagrant.plugin('2', :config)
        include KeyMixin
        # @!parse extend KeyMixin::ClassMethods

        # @return [String] the HTTP proxy
        key :http, env_var: 'VAGRANT_ENV_HTTP_PROXY'

        # @return [String] the HTTPS proxy
        key :https, env_var: 'VAGRANT_ENV_HTTPS_PROXY'

        # @return [String] the FTP proxy
        key :ftp, env_var: 'VAGRANT_ENV_FTP_PROXY'

        # @return [String] a comma separated list of hosts or domains which do not use proxies
        key :no_proxy, env_var: 'VAGRANT_ENV_NO_PROXY'

        private

        # (see KeyMixin#config_for)
        def config_for(key, value)
          if value
            var = env_variable_name(key)
            [var.upcase, var.downcase].map { |v| "export #{v}=#{value}\n" }.join
          end
        end

        def env_variable_name(key)
          key.name == :no_proxy ? "no_proxy" : "#{key.name}_proxy"
        end
      end
    end
  end
end
