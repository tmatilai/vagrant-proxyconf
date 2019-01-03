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

        def configure_machine
          set_or_delete_proxy('proxy', config.http)
          set_or_delete_proxy('https-proxy', config.https)
          set_or_delete_proxy('noproxy', config.no_proxy)
        end

        def unconfigure_machine
          config.http = nil
          config.https = nil
          config.no_proxy = nil
          configure_machine

          true
        end

        def set_or_delete_proxy(key, value)
          return if !supported?

          command = "#{npm_path} config --global "
          if value
            command << "set #{key} #{escape(value)}"
          else
            command << "delete #{key}"

            # ensure that the npmrc file exists to work around
            # https://github.com/npm/npm/issues/5065
            @machine.communicate.sudo("#{npm_path} config --global set #{key} foo")
          end
          @machine.communicate.sudo(command)

          true
        end

        def npm_path
          @machine.guest.capability(cap_name)
        end
      end
    end
  end
end
