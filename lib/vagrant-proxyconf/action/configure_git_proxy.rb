require_relative 'base'
require_relative '../resource'
require_relative '../userinfo_uri'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Git on the guest
      class ConfigureGitProxy < Base
        def config_name
          'git_proxy'
        end

        private

        def configure_machine(machine, config)
          if machine.guest.capability(:git_proxy_conf)
            machine.communicate.sudo("git config --system http.proxy #{config.http}")
          else
            write_config(machine, git_config(config), path: '/etc/gitconfig', append: true)
          end
        end

        def git_config(config)
          (<<-CONFIG)

[http]
        proxy = "#{config.http}"
          CONFIG
        end
      end
    end
  end
end
