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

        def configure_machine
          return if !supported?

          logger.info('Writing the proxy configuration to docker config')
          detect_export
          write_docker_config
          update_docker_client_config
          update_docker_systemd_config

          true
        end

        def unconfigure_machine
          return if !supported?

          config.http = nil
          config.https = nil
          config.no_proxy = nil

          write_docker_config
          update_docker_client_config
          update_docker_systemd_config

          true
        end

        def docker_client_config_path
          return @docker_client_config_path if @docker_client_config_path
          return if !supports_config_json?

          @docker_client_config_path = tempfile(Hash.new)

          @machine.communicate.tap do |comm|
            if comm.test("[ -f /etc/docker/config.json ]")
              logger.info('Downloading file /etc/docker/config.json')
              comm.sudo("chmod 0644 /etc/docker/config.json")
              comm.download("/etc/docker/config.json", @docker_client_config_path.path)
              logger.info("Downloaded /etc/docker/config.json to #{@docker_client_config_path.path}")
            end
          end

          @docker_client_config_path = @docker_client_config_path.path
        end

        def update_docker_client_config
          return if !supports_config_json? || !docker_client_config_path

          content = File.read(@docker_client_config_path)
          data  = JSON.load(content)

          if disabled?
            data['proxies'] = {
              'default' => {}
            }
          else

            data['proxies'] = {} unless data.key?('proxies')
            data['proxies']['default'] = {} unless data['proxies'].key?('default')

            data['proxies']['default'].delete('httpProxy')
            data['proxies']['default'].delete('httpsProxy')
            data['proxies']['default'].delete('noProxy')

            unless config.http == false || config.http == "" || config.http.nil?
              data['proxies']['default']['httpProxy'] = config.http
            end

            unless config.https == false || config.https == "" || config.https.nil?
              data['proxies']['default']['httpsProxy'] = config.https
            end

            unless config.no_proxy == false || config.no_proxy == "" || config.no_proxy.nil?
              data['proxies']['default']['noProxy'] = config.no_proxy
            end

          end

          config_json = JSON.pretty_generate(data)

          @docker_client_config_path = tempfile(config_json)

          @machine.communicate.tap do |comm|
            comm.upload(@docker_client_config_path.path, "/tmp/vagrant-proxyconf-docker-config.json")
            comm.sudo("mkdir -p /etc/docker")
            comm.sudo("chown root:docker /etc/docker")
            comm.sudo("mv /tmp/vagrant-proxyconf-docker-config.json /etc/docker/config.json")
            comm.sudo("chown root:docker /etc/docker/config.json")
            comm.sudo("chmod 0644 /etc/docker/config.json")
            comm.sudo("rm -f /tmp/vagrant-proxyconf-docker-config.json")

            comm.sudo("sed -i.bak -e '/^DOCKER_CONFIG/d' /etc/environment")
            if !disabled?
              comm.sudo("echo DOCKER_CONFIG=/etc/docker >> /etc/environment")
            end
          end

          config_json
        end

        def update_docker_systemd_config
          return if !supports_systemd?
          changed = false

          if disabled?
            @machine.communicate.tap do |comm|
              changed = true if comm.test('[ -f /etc/systemd/system/docker.service.d/http-proxy.conf ]')
              changed = true if comm.test('[ -f /etc/systemd/system/docker.service.d/https-proxy.conf ]')

              comm.sudo('rm -f /etc/systemd/system/docker.service.d/http-proxy.conf')
              comm.sudo('rm -f /etc/systemd/system/docker.service.d/https-proxy.conf')
              comm.sudo('systemctl daemon-reload')

              if changed
                comm.sudo("systemctl restart #{docker}")
              end

            end

            changed = true
            return changed
          end

          systemd_config = docker_systemd_config
          @docker_systemd_config = tempfile(systemd_config).path

          @machine.communicate.tap do |comm|

            comm.sudo("mkdir -p /etc/systemd/system/docker.service.d")
            comm.upload(@docker_systemd_config, "/tmp/vagrant-proxyconf-docker-systemd-config")

            if comm.test("diff -Naur /etc/systemd/system/docker.service.d/http-proxy.conf /tmp/vagrant-proxyconf-docker-systemd-config")
              # system config file is the same as the current config

              changed = false
            else
              # system config file is not the same as the current config

              comm.sudo("mv /tmp/vagrant-proxyconf-docker-systemd-config /etc/systemd/system/docker.service.d/http-proxy.conf")
              changed = true
            end

            comm.sudo('chown -R 0:0 /etc/systemd/system/docker.service.d/')
            comm.sudo('touch /etc/systemd/system/docker.service.d/http-proxy.conf')
            comm.sudo('chmod 0644 /etc/systemd/system/docker.service.d/http-proxy.conf')

            if changed
              # there were changes so restart docker

              comm.sudo('systemctl daemon-reload')
              comm.sudo("systemctl restart #{docker}")
            end

          end

          changed

        end

        def docker
          if config_path && config_path.include?('docker.io')
            'docker.io'
          else
            'docker'
          end
        end

        def docker_version
          return if !supported?
          return @version if @version

          @version = nil
          @machine.communicate.execute('docker --version') do |type, data|
            version = data.sub(',', '').split(' ').select {|i| i.match /^\d+\.\d+/}
            @version = version[0].split(".").map {|i| i.to_i} unless version.empty?
          end

          return @version
        end

        def supports_config_json?
          return false if !supported? || !docker_version

          major, minor, patch = @version

          # https://docs.docker.com/network/proxy/#configure-the-docker-client
          # if docker version >= 17.07 it supports config.json
          # docker version < 17.07 so it does not support config.json
          return false if major <= 17 && minor < 7

          # docker version must be >= 17.07 so we return true
          return true
        end

        def supports_systemd?

          @machine.communicate.tap do |comm|
            comm.test('command -v systemctl') ? true : false
          end

        end

        def write_docker_config
          tmp = "/tmp/vagrant-proxyconf"
          path = config_path

          @machine.communicate.tap do |comm|
            sed_script = docker_sed_script
            local_tmp = !disabled? ? tempfile(docker_config) : tempfile("")

            comm.sudo("rm -f #{tmp}", error_check: false)
            comm.upload(local_tmp.path, tmp)
            comm.sudo("touch #{path}")
            comm.sudo("sed -e '#{sed_script}' #{path} > #{path}.new")
            comm.sudo("cat #{tmp} >> #{path}.new")
            update_config(comm, path)
            comm.sudo("rm -f #{tmp} #{path}.new")
          end
        end

        def update_config(comm, path)
          return if comm.test("diff #{path}.new #{path}")

          # update config and restart docker when config changed
          comm.sudo("chmod 0644 #{path}.new")
          comm.sudo("chown root:docker #{path}.new")
          comm.sudo("mv -f #{path}.new #{path}")
          comm.sudo(service_restart_command)
        end

        def detect_export
          @machine.communicate.tap do |comm|
            supports_systemd? ? @export = '' : @export = 'export '
          end
        end

        def service_restart_command
          [
            "kill -HUP `pgrep -f '#{docker}'`",
            "systemctl restart #{docker}",
            "service #{docker} restart",
            "/etc/init.d/#{docker} restart",
          ].join(' || ')
        end

        def docker_sed_script
          <<-SED.gsub(/^\s+/, '')
            /^#{@export}HTTP_PROXY=/ d
            /^#{@export}http_proxy=/ d
            /^#{@export}HTTPS_PROXY=/ d
            /^#{@export}https_proxy=/ d
            /^#{@export}NO_PROXY=/ d
            /^#{@export}no_proxy=/ d
          SED
        end

        def docker_config
          <<-CONFIG.gsub(/^\s+/, '')
            #{@export}HTTP_PROXY=\"#{config.http || ''}\"
            #{@export}http_proxy=\"#{config.http || ''}\"
            #{@export}HTTPS_PROXY=\"#{config.https || ''}\"
            #{@export}https_proxy=\"#{config.https || ''}\"
            #{@export}NO_PROXY=\"#{config.no_proxy || ''}\"
            #{@export}no_proxy=\"#{config.no_proxy || ''}\"
          CONFIG
        end

        def docker_systemd_config
          return if disabled?

          environment = []
          environment << 'Environment="HTTP_PROXY='  + config.http     + '"' if config.http
          environment << 'Environment="HTTPS_PROXY=' + config.https    + '"' if config.https
          environment << 'Environment="NO_PROXY='    + config.no_proxy + '"' if config.no_proxy

          return if !environment.any?

          <<-SYSTEMD.gsub(/^\s+/, '')
            [Service]
            #{environment.join("\n")}
          SYSTEMD
        end

      end
    end
  end
end
