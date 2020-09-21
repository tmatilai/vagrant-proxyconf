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
            docker_command = find_docker_command(machine)
            return false if docker_command.nil?

            config_path = CONFIG_DIR + docker_command
            return config_path unless Util.which(machine, 'systemctl')

            machine.communicate.tap do |comm|
              src_file = "/lib/systemd/system/#{docker_command}.service"
              dst_file = "/etc/systemd/system/#{docker_command}.service"
              tmp_file = "/tmp/#{docker_command}.service"
              env_file = "EnvironmentFile=-\\/etc\\/default\\/#{docker_command}"
              if comm.test("grep -q -e '#{env_file}' #{src_file}")
                comm.sudo("cp -p #{src_file} #{tmp_file}")
              else
                comm.sudo("sed -e 's/\\[Service\\]/[Service]\\n#{env_file}/g' #{src_file} > #{tmp_file}")
              end
              unless comm.test("diff #{tmp_file} #{dst_file}")
                # update config and restart docker when config changed
                comm.sudo("mv -f #{tmp_file} #{dst_file}")
                # identify which init system you are currently booting with
                # ps -p1 | grep -q systemd && echo systemd || echo upstart
                # see also https://wiki.ubuntu.com/SystemdForUpstartUsers
                if comm.test("ps -p1 | grep -q systemd")
                  comm.sudo("systemctl FOOO1 daemon-reload")
                  comm.sudo("systemctl FOOO1 restart #{docker_command}")
                elsif comm.test("ps -p1 | grep -v -q systemd")
                  comm.sudo("initctl reload-configuration")
                  comm.sudo("initctl reload #{docker_command}")
                  comm.sudo("initctl restart #{docker_command}")
                else
                  comm.sudo("systemctl restart docker || systemctl restart docker.io || service docker restart || service docker.io restart || /etc/init.d/docker restart || /etc/init.d/docker.io restart || kill -HUP `pgrep -f 'docker'` || kill -HUP `pgrep -f 'docker.io'` ")
                  #allow(machine).to receive_message_chain(:communicate, :sudo).with("kill -HUP `pgrep -f 'docker'` || systemctl restart docker || service docker restart || /etc/init.d/docker restart")
                  #comm.sudo("systemctl daemon-reload ; initctl reload-configuration \|\| true")
                  #comm.sudo("systemctl daemon-reload \|\| true")
                  #comm.sudo("initctl reload-configuration \|\| true")
                end
              end
              comm.sudo("rm -f #{tmp_file}")
            end
            config_path
          end

          private

          def self.find_docker_command(machine)
            return 'docker'    if Util.which(machine, 'docker')
            return 'docker.io' if Util.which(machine, 'docker.io')
            nil
          end
        end
      end
    end
  end
end
