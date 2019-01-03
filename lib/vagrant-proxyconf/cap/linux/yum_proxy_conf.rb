module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for Yum proxy configuration
        module YumProxyConf
          # @return [String] the path to the configuration file
          def self.yum_proxy_conf(machine)
            machine.communicate.tap do |comm|
              return '/etc/yum.conf' if comm.test('[ -f /etc/yum.conf ]')
              return '/etc/yum/yum.conf' if comm.test('[ -f /etc/yum/yum.conf ]')
            end
            nil
          end
        end
      end
    end
  end
end
