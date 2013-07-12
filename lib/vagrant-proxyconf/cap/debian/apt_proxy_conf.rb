module VagrantPlugins
  module ProxyConf
    module Cap
      module Debian
        # Capability for Apt proxy configuration
        module AptProxyConf
          # @return [String] the path to the configuration file
          def self.apt_proxy_conf(machine)
            '/etc/apt/apt.conf.d/01proxy'
          end
        end
      end
    end
  end
end
