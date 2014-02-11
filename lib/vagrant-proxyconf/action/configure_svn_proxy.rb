require_relative 'base'
require_relative '../userinfo_uri'

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
          u = UserinfoURI.new(config.http)
          no_proxy = config.no_proxy

          config = (<<-CONFIG)
[global]
http-proxy-host=#{u.host}
http-proxy-port=#{u.port}
          CONFIG

          config.concat("http-proxy-username=#{u.user}") if u.user
          config.concat("http-proxy-password=#{u.pass}") if u.pass
          config.concat("http-proxy-exceptions=#{no_proxy}") if no_proxy

          config
        end
      end
    end
  end
end
