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

          <<-CONFIG.gsub(/^. */, '')
          [global]
          http-proxy-host=#{u.host}
          http-proxy-port=#{u.port}
          http-proxy-username=#{u.user}
          http-proxy-password=#{u.pass}
          http-proxy-exceptions=#{config.no_proxy}
          CONFIG
        end
      end
    end
  end
end
