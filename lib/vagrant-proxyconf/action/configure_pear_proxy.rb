require_relative 'base'

# Should only execute if pear is present
# test -x /usr/bin/pear

# should run following:
# pear config-set http_proxy 'http://...'

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
          comm.sudo("pear config-set http_proxy #{escape(config.http)} system")
        end
      end
    end
  end
end
