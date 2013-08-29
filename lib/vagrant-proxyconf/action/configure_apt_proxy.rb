require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Apt on the guest
      class ConfigureAptProxy < Base
        def config_name
          'apt_proxy'
        end
      end
    end
  end
end
