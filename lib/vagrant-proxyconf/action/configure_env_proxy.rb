require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring proxy environment variables on the guest
      class ConfigureEnvProxy < Base
        def config_name
          'env_proxy'
        end

        private

        def configure_machine
          if windows_guest?
            logger.info('Setting the Windows proxy environment variables')
            configure_machine_windows
          else
            logger.info('Writing the proxy configuration to files')
            super
            write_config(sudo_config, path: '/etc/sudoers.d/proxy', mode: '0440')
          end
        end

        def configure_machine_windows
          set_windows_proxy('http_proxy', config.http)
          set_windows_proxy('https_proxy', config.https)
          set_windows_proxy('ftp_proxy', config.ftp)
          set_windows_proxy('no_proxy', config.no_proxy)
        end

        def sudo_config
          <<-CONFIG.gsub(/^\s+/, '')
            Defaults env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY"
            Defaults env_keep += "http_proxy https_proxy ftp_proxy no_proxy"
          CONFIG
        end

        def set_windows_proxy(key, value)
          if value
            command = "cmd.exe /c SETX #{key} #{escape(value)} /M"
            logger.info("Setting #{key} to #{value}")
            @machine.communicate.sudo(command)
          else
            logger.info("Not setting #{key}")
          end
        end

        def windows_guest?
          @machine.config.vm.guest.eql?(:windows)
        end

      end
    end
  end
end
