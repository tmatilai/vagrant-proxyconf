module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for PEAR proxy configuration
        module PearProxyConf
          # @return [Boolean] if PEAR is installed
          def self.pear_proxy_conf(machine)
            machine.communicate.test("which pear")
          end
        end
      end
    end
  end
end
