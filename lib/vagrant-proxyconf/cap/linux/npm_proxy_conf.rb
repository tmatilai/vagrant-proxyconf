module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for npm proxy configuration
        module NpmProxyConf
          # @return [Boolean] if npm is installed
          def self.npm_proxy_conf(machine)
            machine.communicate.test('which npm', sudo: true)
          end
        end
      end
    end
  end
end
