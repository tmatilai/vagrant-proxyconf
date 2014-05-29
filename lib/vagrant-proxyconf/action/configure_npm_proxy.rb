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
          command = "#{npm_path} config "
          if value
            command << "set #{key} #{escape(value)}"
          else
            command << "delete #{key}"

            # ensure that the .npmrc file exists to work around
            # https://github.com/npm/npm/issues/5065
            @machine.communicate.sudo("touch ~/.npmrc")
          end
          @machine.communicate.sudo(command)
        end

        def npm_path
          @machine.guest.capability(cap_name)
        end
      end
    end
  end
end
