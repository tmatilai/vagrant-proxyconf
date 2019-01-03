require_relative '../util'

module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for docker proxy configuration
        module DockerProxyConf
          # @return [String, false] the path to docker or `false` if not found
          def self.docker_proxy_conf(machine)
            docker_command = 'docker'    if Util.which(machine, 'docker')
            docker_command = 'docker.io' if Util.which(machine, 'docker.io')

            return false if docker_command.nil?

            if machine.communicate.test('[ -f /etc/redhat-release ]')
              "/etc/sysconfig/#{docker_command}"
            elsif machine.communicate.test('ls /var/lib/boot2docker/')
              "/var/lib/boot2docker/profile"
            else
              "/etc/default/#{docker_command}"
            end
          end

        end
      end
    end
  end
end
