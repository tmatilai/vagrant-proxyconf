require_relative '../util'

module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for chef  proxy configuration
        module ChefProxyConf
          # @return [String, false] the path to chef or `false` if not found
          def self.chef_proxy_conf(machine)
            Util.which(machine, 'chef-client')
          end
        end
      end
    end
  end
end
