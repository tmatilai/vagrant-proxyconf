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

          sed_script = docker_sed_script
          local_tmp = tempfile(docker_config)

          @machine.communicate.tap do |comm|
            comm.sudo("rm #{tmp}", error_check: false)
            comm.upload(local_tmp.path, tmp)
            comm.sudo("touch #{path}")
            comm.sudo("sed -e '#{sed_script}' #{path} > #{path}.new")
            comm.sudo("cat #{tmp} >> #{path}.new")
            comm.sudo("chmod 0644 #{path}.new")
            comm.sudo("chown root:root #{path}.new")
            comm.sudo("mv #{path}.new #{path}")
            comm.sudo("rm #{tmp}")
            comm.sudo("service #{docker} restart || /etc/init.d/#{docker} restart")
          end
        end

        def docker_sed_script
          <<-SED.gsub(/^\s+/, '')
            /^export HTTP_PROXY=/ d
            /^export NO_PROXY=/ d
            /^export http_proxy=/ d
            /^export no_proxy=/ d
          SED
        end

        def docker_config
          <<-CONFIG.gsub(/^\s+/, '')
            export HTTP_PROXY=#{config.http || ''}
            export NO_PROXY=#{config.no_proxy || ''}
            export http_proxy=#{config.http || ''}
            export no_proxy=#{config.no_proxy || ''}
          CONFIG
        end
      end
    end
  end
end
