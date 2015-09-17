require_relative '../util'

module VagrantPlugins
  module ProxyConf
    module Cap
      module Debian
        # Capability for docker proxy configuration
        module DockerProxyConf
          CONFIG_DIR = '/etc/default/'

          # @return [String, false] the path to docker or `false` if not found
          def self.docker_proxy_conf(machine)
            docker_command = 'docker'    if Util.which(machine, 'docker')
            docker_command = 'docker.io' if Util.which(machine, 'docker.io')

            return false if docker_command.nil?

            config_path = CONFIG_DIR + docker_command
            return config_path unless Util.which(machine, 'systemctl')

            machine.communicate.tap do |comm|
              src_file = '/lib/systemd/system/docker.service'
              dst_file = '/etc/systemd/system/docker.service'
              tmp_file = '/tmp/docker.service'
              env_file = 'EnvironmentFile=-\/etc\/default\/docker'
              if comm.test("grep -q -e '#{env_file}' #{src_file}")
                comm.sudo("cp -p #{src_file} #{tmp_file}")
              else
                comm.sudo("sed -e 's/\\[Service\\]/[Service]\\n#{env_file}/g' #{src_file} > #{tmp_file}")
              end
              unless comm.test("diff #{tmp_file} #{dst_file}")
                # update config and restart docker when config changed
                comm.sudo("mv -f #{tmp_file} #{dst_file}")
                comm.sudo('systemctl daemon-reload')
              end
              comm.sudo("rm -f #{tmp_file}")
            end
            config_path
          end
        end
      end
    end
  end
end
