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
          if @machine.guest.capability(:git_proxy_conf)
            @machine.communicate.sudo("git config --system http.proxy #{config.http}")
          else
            write_config(git_config, path: '/etc/gitconfig', append: true)
          end
        end

        def git_config
          (<<-CONFIG)

[http]
        proxy = "#{config.http}"
          CONFIG
        end
      end
    end
  end
end
