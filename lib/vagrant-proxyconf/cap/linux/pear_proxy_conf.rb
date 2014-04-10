require_relative '../util'

module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for PEAR proxy configuration
        module PearProxyConf
          # @return [String, false] the path to pear or `false` if not found
          def self.pear_proxy_conf(machine)
            Util.which(machine, 'pear')
          end
        end
      end
    end
  end
end
