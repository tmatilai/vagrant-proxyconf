require_relative 'base'
require_relative '../resource'
require_relative '../userinfo_uri'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring systemd on the guest
      class ConfigureSystemdProxy < Base
        def config_name
          'systemd_proxy'
        end

        private

        def config
          # Use global proxy config
          @config ||= finalize_config(@machine.config.proxy)
        end

        def configure_machine
          logger.info('Writing the proxy configuration to systemd config')
          write_systemd_config
        end

        def write_systemd_config
          path = config_path

          @machine.communicate.tap do |comm|
            if (comm.sudo(" systemctl show-environment | grep -c \"http_proxy=#{config.http || ''}\"").to_i rescue 0) == 0
              comm.sudo("echo -e '#{systemd_env_settings}' >> #{path}")
              comm.sudo(service_restart_command_low)
              comm.sudo(service_restart_command_up)
            end
          end
        end

        def service_restart_command_up
          "systemctl set-environment \"HTTP_PROXY=#{config.http || ''}\" && " +
            "systemctl set-environment \"HTTPS_PROXY=#{config.https || ''}\" && " +
            "systemctl set-environment \"NO_PROXY=#{config.no_proxy || ''}\""
        end

        def service_restart_command_low
          "systemctl set-environment \"http_proxy=#{config.http || ''}\" && " +
            "systemctl set-environment \"https_proxy=#{config.https || ''}\" && " +
            "systemctl set-environment \"no_proxy=#{config.no_proxy || ''}\" "
        end

        def systemd_env_settings
          "DefaultEnvironment=\"https_proxy=#{config.http || ''}\" "+
            "\"http_proxy=#{config.http || ''}\" "+
            "\"no_proxy=#{config.no_proxy || ''}\""
        end

      end
    end
  end
end
