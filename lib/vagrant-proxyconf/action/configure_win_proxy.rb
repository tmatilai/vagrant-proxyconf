require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Windows proxy on the windows guest
      class ConfigureWinProxy < Base
        def config_name
          'env_proxy'
        end

        private

        # @return [Vagrant::Plugin::V2::Config] the configuration
        def config
          return @config if @config

          # Use only `config.env_proxy`, don't merge with the default config
          @config = @machine.config.env_proxy
          finalize_config(@config)
        end

        def configure_machine
          logger.info('Setting the Windows Proxy environment variables')
          set_proxy('http_proxy', config.http)
          set_proxy('https_proxy', config.https)
          set_proxy('ftp_proxy', config.ftp)
          set_proxy('no_proxy', "\"#{config.no_proxy}\"")
        end

        def set_proxy(key, value)
          if value
            command = "cmd.exe /c SETX #{key} #{value} /M"
            logger.info("Setting #{key} to #{value}")
            @machine.communicate.sudo(command)
          else
            logger.info("Not setting #{key}")
          end
        end

      end
    end
  end
end
