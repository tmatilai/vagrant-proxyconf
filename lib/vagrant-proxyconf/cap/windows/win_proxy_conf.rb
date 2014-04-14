require_relative '../util'

module VagrantPlugins
  module ProxyConf
    module Cap
      module Windows
        # Capability for git proxy configuration
        module WinProxyConf
          # @return [String, false]
          def self.win_proxy_conf(machine)
            return true
          end
        end
      end
    end
  end
end
