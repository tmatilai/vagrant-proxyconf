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
          set_or_delete_proxy('http_proxy', config.http)
          set_or_delete_proxy('https_proxy', config.https)
          set_or_delete_proxy('ftp_proxy', config.ftp_proxy)
          set_or_delete_proxy('no_proxy', config.no_proxy)
        end

        def set_or_delete_proxy(key, value)
          command = "cmd.exe /c SETX "
          if value
            command << "#{key} #{escape(value)}"
          else
            command << key
          end
          logger.info("Setting #{key} to #{value}")
          @machine.communicate.sudo(command)
        end

      end
    end
  end
end
