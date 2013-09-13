require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring proxy environment variables on the guest
      class ConfigureEnvProxy < Base
        def config_name
          'env_proxy'
        end

        private

        def configure_machine(machine, config)
          super
          write_config(machine, sudo_config, path: '/etc/sudoers.d/proxy', mode: '0440')
        end

        def sudo_config
          <<-CONFIG.gsub(/^\s+/, '')
            Defaults env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY"
            Defaults env_keep += "http_proxy https_proxy ftp_proxy no_proxy"
          CONFIG
        end
      end
    end
  end
end
