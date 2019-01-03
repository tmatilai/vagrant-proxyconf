require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Apt on the guest
      class ConfigureAptProxy < Base
        def config_name
          'apt_proxy'
        end

        private

        def unconfigure_machine
          if !supported?
            logger.info "apt_proxy is not supported on '#{@machine.guest.name}'"
            return false
          end

          logger.info "apt_proxy is supported on '#{@machine.guest.name}'"

          # if we get here then machine should support unconfiguring
          @machine.communicate.sudo("rm -f #{config_path}")

          true
        end

      end
    end
  end
end
