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

        # @return [Vagrant::Plugin::V2::Config] the configuration
        def config
          return @config if @config

          # Use only `config.git_proxy`, don't merge with the default config
          @config = @machine.config.git_proxy
          finalize_config(@config)
        end

        def configure_machine
          @machine.communicate.sudo(
            "git config --system http.proxy #{config.http}")
        end
      end
    end
  end
end
