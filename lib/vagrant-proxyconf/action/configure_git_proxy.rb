require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Git on the guest
      class ConfigureGitProxy < Base
        def config_name
          'git_proxy'
        end

        private

        def configure_machine
          @machine.communicate.sudo(
            "git config --system http.proxy #{config.http}")
        end
      end
    end
  end
end
