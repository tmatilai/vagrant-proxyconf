require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Windows proxy on the windows guest
      class ConfigureWinProxy < Base
        def config_name
          'win_proxy'
        end

        private

        # @return [Vagrant::Plugin::V2::Config] the configuration
        def config
          return @config if @config

          # Use only `config.win_proxy`, don't merge with the default config
          @config = @machine.config.win_proxy
          finalize_config(@config)
        end

        def configure_machine
          logger.info('Setting the Windows Proxy environment variables')

          if config.http
            logger.info("Setting http_proxy to #{config.http}")
            @machine.communicate.sudo("cmd.exe /c SETX http_proxy #{config.http}")
          end

          if config.https
            logger.info("Setting https_proxy to #{config.https}")
            @machine.communicate.sudo("cmd.exe /c SETX https_proxy #{config.https}")
          end

          if config.ftp
            logger.info("Setting ftp_proxy to #{config.ftp}")
            @machine.communicate.sudo("cmd.exe /c SETX ftp_proxy #{config.ftp}")
          end

          if config.no_proxy
            logger.info("Setting no_proxy to #{config.no_proxy}")
            @machine.communicate.sudo("cmd.exe /c SETX no_proxy \"#{config.no_proxy}\"")
          end

        end

      end
    end
  end
end