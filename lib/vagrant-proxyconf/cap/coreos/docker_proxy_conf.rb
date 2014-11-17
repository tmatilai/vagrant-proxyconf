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
              src_file='/usr/lib/systemd/system/docker.service'
              tmp_file='/tmp/docker.service'
              env_file='EnvironmentFile=-\/etc\/default\/docker'
              comm.sudo("\\sed -e 's/\\[Service\\]/[Service]\\n#{env_file}/g' #{src_file} > #{tmp_file}")

              comm.sudo('\\mv /tmp/docker.service /etc/systemd/system/')
              comm.sudo('\\systemctl daemon-reload')
            end
            '/etc/default/docker'
          end
        end
      end
    end
  end
end
