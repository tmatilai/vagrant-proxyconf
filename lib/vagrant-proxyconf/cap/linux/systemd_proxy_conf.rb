require_relative '../util'

module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for systemd proxy configuration
        module SystemdProxyConf
          # @return [String, false] the path to systemd or `false` if not found
          def self.systemd_proxy_conf(machine)
            systemd_command = 'systemctl' if Util.which(machine, 'systemctl')
            return false if systemd_command.nil?

            '/etc/systemd/system.conf'
          end
        end
      end
    end
  end
end
