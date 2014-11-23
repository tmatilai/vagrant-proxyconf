require_relative 'base'
require_relative '../resource'
require_relative '../userinfo_uri'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Docker on the guest
      class ConfigureDockerProxy < Base
        def config_name
          'docker_proxy'
        end

        private

        def config
          # Use global proxy config
          @config ||= finalize_config(@machine.config.proxy)
        end

        def configure_machine
          logger.info('Writing the proxy configuration to docker config')
          detect_export
          write_docker_config
        end

        def docker
          if config_path && config_path.include?('docker.io')
            'docker.io'
          else
            'docker'
          end
        end

        def write_docker_config
          tmp = "/tmp/vagrant-proxyconf"
          path = config_path

          @machine.communicate.tap do |comm|
            sed_script = docker_sed_script
            local_tmp = tempfile(docker_config)

            comm.sudo("rm #{tmp}", error_check: false)
            comm.upload(local_tmp.path, tmp)
            comm.sudo("touch #{path}")
            comm.sudo("sed -e '#{sed_script}' #{path} > #{path}.new")
            comm.sudo("cat #{tmp} >> #{path}.new")
            unless comm.test("diff #{path}.new #{path}")
              # update config and restart docker when config changed
              comm.sudo("chmod 0644 #{path}.new")
              comm.sudo("chown root:root #{path}.new")
              comm.sudo("mv #{path}.new #{path}")
              comm.sudo(service_restart_command)
            end
            comm.sudo("rm -f #{tmp} #{path}.new")
          end
        end

        def detect_export
          @machine.communicate.tap do |comm|
            comm.test('which systemctl') ? @export = '' : @export = 'export '
          end
        end

        def service_restart_command
          ["systemctl restart #{docker}",
            "service #{docker} restart",
            "/etc/init.d/#{docker} restart"].join(' || ')
        end

        def docker_sed_script
          <<-SED.gsub(/^\s+/, '')
            /^#{@export}HTTP_PROXY=/ d
            /^#{@export}NO_PROXY=/ d
            /^#{@export}http_proxy=/ d
            /^#{@export}no_proxy=/ d
          SED
        end

        def docker_config
          <<-CONFIG.gsub(/^\s+/, '')
            #{@export}HTTP_PROXY=#{config.http || ''}
            #{@export}NO_PROXY=#{config.no_proxy || ''}
            #{@export}http_proxy=#{config.http || ''}
            #{@export}no_proxy=#{config.no_proxy || ''}
          CONFIG
        end
      end
    end
  end
end
