require_relative '../util'

module VagrantPlugins
  module ProxyConf
    module Cap
      module Windows
        # Capability for windows host proxy configuration
        module EnvProxyConf
          # @return [String, false]
          def self.env_proxy_conf(machine)
            return true
          end
        end
      end
    end
  end
end
