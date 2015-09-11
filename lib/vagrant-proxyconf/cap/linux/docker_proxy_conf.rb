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

            if machine.communicate.test('cat /etc/redhat-release')
              "/etc/sysconfig/#{docker_command}"
            elsif machine.communicate.test('ls /var/lib/boot2docker/')
              "/var/lib/boot2docker/profile"
            elsif machine.communicate.test('ps -p1 | grep systemd')
              machine.communicate.tap do |comm|
                src_file = "/lib/systemd/system/#{docker_command}.service"
                dst_file = "/etc/systemd/system/#{docker_command}.service"
                tmp_file = "/tmp/#{docker_command}.service"
                env_file = "EnvironmentFile=-\\/etc\\/default\\/#{docker_command}"
                comm.sudo("sed -e 's/\\[Service\\]/[Service]\\n#{env_file}/g' #{src_file} > #{tmp_file}")
                unless comm.test("diff #{tmp_file} #{dst_file}")
                  # update config and restart docker when config changed
                  comm.sudo("mv -f #{tmp_file} #{dst_file}")
                  comm.sudo('systemctl daemon-reload')
                end
                comm.sudo("rm -f #{tmp_file}")
              end
              "/etc/default/#{docker_command}"
            else
              "/etc/default/#{docker_command}"
            end
          end
        end
      end
    end
  end
end
