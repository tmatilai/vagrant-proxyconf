module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for Env proxy configuration
        module EnvProxyConf
          # @return [String] the path to the configuration file
          def self.env_proxy_conf(machine)
            '/etc/profile.d/proxy.sh'
          end
        end
      end
    end
  end
end
