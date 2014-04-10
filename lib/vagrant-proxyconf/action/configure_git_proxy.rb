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
          command = "#{git_path} config --system "
          if config.http
            command << "http.proxy #{config.http}"
          else
            command << "--unset-all http.proxy"
          end
          @machine.communicate.sudo(command)
        end

        def git_path
          @machine.guest.capability(cap_name)
        end
      end
    end
  end
end
