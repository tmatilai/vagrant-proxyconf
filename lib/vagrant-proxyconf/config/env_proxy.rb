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

        def validate(machine)
          if enabled?
            puts 'DEPRECATION: `config.env_proxy.*` and `VAGRANT_ENV_*_PROXY`'
            puts 'configuration is deprecated and will be removed in v2.0.0.'
            puts 'Please use `config.proxy.*` and `VAGRANT_*_PROXY` instead.'
            puts
          end
          super
        end

        private

        # (see KeyMixin#config_for)
        def config_for(key, value)
          if value
            var = env_variable_name(key)

            # Quote the `no_proxy` value in case there are spaces and special
            # characters. Unfortunately we can't escape other values before
            # v2.0 as even the README had an example of using shell variables
            # still in v1.0.x.
            value = value.inspect if key.name == :no_proxy

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
