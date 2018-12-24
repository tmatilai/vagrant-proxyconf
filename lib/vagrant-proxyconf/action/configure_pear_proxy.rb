require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Pear on the guest
      class ConfigurePearProxy < Base
        def config_name
          'pear_proxy'
        end

        private

        def configure_machine
          return if !supported?

          config.http = nil if disabled?
          proxy = config.http || ''

          @machine.communicate.sudo("#{pear_path} config-set http_proxy #{escape(proxy)} system")

          true
        end

        def unconfigure_machine
          return if !supported?

          config.http = nil
          configure_machine

          true
        end

        def pear_path
          @machine.guest.capability(cap_name)
        end
      end
    end
  end
end
