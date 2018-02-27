require_relative '../util'

module VagrantPlugins
  module ProxyConf
    module Cap
      module CoreOS
        # Capability for docker proxy configuration
        module DockerProxyConf
          # @return [String, false] the path to docker or `false` if not found
          def self.docker_proxy_conf(machine)
            return false unless Util.which(machine, 'docker')

            machine.communicate.tap do |comm|
              src_file = '/run/systemd/system/docker.service'
              dst_file = '/etc/systemd/system/docker.service'
              tmp_file = '/tmp/docker.service'
              env_file = 'EnvironmentFile=-\/etc\/default\/docker'
              comm.sudo("sed -e 's/\\[Service\\]/[Service]\\n#{env_file}/g' #{src_file} > #{tmp_file}")
              unless comm.test("diff #{tmp_file} #{dst_file}")
                # update config and restart docker when config changed
                comm.sudo("mv -f #{tmp_file} #{dst_file}")
                comm.sudo('systemctl daemon-reload')
              end
              comm.sudo("rm -f #{tmp_file}")
            end
            '/etc/default/docker'
          end
        end
      end
    end
  end
end
