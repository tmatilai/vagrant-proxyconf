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
          return if !supported?

          if config.http
            @machine.communicate.sudo(
              "#{git_path} config --system http.proxy #{config.http}")
          else
            @machine.communicate.sudo(
              "#{git_path} config --system --unset-all http.proxy",
              error_check: false)
          end

          if config.https
            @machine.communicate.sudo(
              "#{git_path} config --system https.proxy #{config.https}")
          else
            @machine.communicate.sudo(
              "#{git_path} config --system --unset-all https.proxy",
              error_check: false)
          end

          true
        end

        def unconfigure_machine
          return if !supported?

          # zero out the configuration
          config.http = nil
          config.https = nil

          configure_machine

          true
        end

        def git_path
          @machine.guest.capability(cap_name)
        end
      end
    end
  end
end
