require_relative '../util'

module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for npm proxy configuration
        module NpmProxyConf
          # @return [String, false] the path to npm or `false` if not found
          def self.npm_proxy_conf(machine)
            Util.which(machine, 'npm')
          end
        end
      end
    end
  end
end
