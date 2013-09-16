module VagrantPlugins
  module ProxyConf
    module Cap
      module Redhat
        # Capability for Yum proxy configuration
        module YumProxyConf
          # @return [String] the path to the configuration file
          def self.yum_proxy_conf(machine)
            '/etc/yum.conf'
          end
        end
      end
    end
  end
end
