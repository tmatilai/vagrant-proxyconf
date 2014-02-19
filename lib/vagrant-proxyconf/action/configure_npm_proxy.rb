require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring npm on the guest
      class ConfigureNpmProxy < Base
        def config_name
          'npm_proxy'
        end

        private

        # @return [Vagrant::Plugin::V2::Config] the configuration
        def config
          # Use global proxy config
          @config ||= finalize_config(@machine.config.proxy)
        end

        def configure_machine
          set_or_delete_proxy('proxy', config.http)
          set_or_delete_proxy('https-proxy', config.https)
        end

        def set_or_delete_proxy(key, value)
          if value
            command = "npm config set #{key} #{escape(config.http)}"
          else
            command = "npm config delete #{key}"
          end
          @machine.communicate.sudo(command)
        end
      end
    end
  end
end
