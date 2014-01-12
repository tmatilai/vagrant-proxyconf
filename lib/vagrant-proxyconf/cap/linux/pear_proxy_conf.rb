module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for Env proxy configuration
        module PearProxyConf
          # @return [String] the path to the configuration file
          def self.pear_proxy_conf(machine)
            '/etc/profile.d/proxy.sh'
          end
        end
      end
    end
  end
end
