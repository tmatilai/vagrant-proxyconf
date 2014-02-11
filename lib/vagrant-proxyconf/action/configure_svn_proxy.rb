require 'uri'
require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Svn on the guest
      class ConfigureSvnProxy < Base
        def config_name
          'svn_proxy'
        end

        private

        # @return [Vagrant::Plugin::V2::Config] the configuration
        def config
          return @config if @config

          # Use only `config.svn_proxy`, don't merge with the default config
          @config = @machine.config.svn_proxy
          finalize_config(@config)
        end

        def configure_machine
          write_config(svn_config, path: '/etc/subversion/servers')
        end

        def svn_config
          uri = URI.parse(config.http)
          user = uri.user
          pass = uri.password
          config = (<<-CONFIG)
[global]
http-proxy-host=#{uri.host}
http-proxy-port=#{uri.port}
          CONFIG

          config.concat("http-proxy-username=#{user}") if user
          config.concat("http-proxy-password=#{pass}") if pass
          config
        end
      end
    end
  end
end
