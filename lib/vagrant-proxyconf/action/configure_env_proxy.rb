require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring proxy environment variables on the guest
      class ConfigureEnvProxy < Base
        def config_name
          'env_proxy'
        end

        private

        def configure_machine
          if windows_guest?
            logger.info('Setting the Windows proxy environment variables')
            configure_machine_windows
          else
            logger.info('Writing the proxy configuration to files')
            super
            write_config(sudo_config, path: '/etc/sudoers.d/proxy', mode: '0440')
            write_environment_config
          end
        end

        def unconfigure_machine
          if windows_guest?
            raise NotImplementedError, 'Sorry but I do not know how to disable a windows proxy yet, please open a feature request'
          end

          logger.info('Unconfiguring and or removing proxy configuration files')
          unconfigure_linux
        end

        def unconfigure_linux
          @machine.communicate.tap do |comm|
            comm.sudo("rm -f /etc/sudoers.d/proxy")
            comm.sudo("rm -f #{config_path}")
          end

          write_environment_config
        end

        def configure_machine_windows
          set_windows_proxy('http_proxy', config.http)
          set_windows_proxy('https_proxy', config.https)
          set_windows_proxy('ftp_proxy', config.ftp)
          set_windows_proxy('no_proxy', config.no_proxy)
          set_windows_system_proxy(config.http)
        end

        def set_windows_proxy(key, value)
          if value
            command = "cmd.exe /c SETX #{key} #{value.inspect} /M"
            logger.info("Setting #{key} to #{value}")
            @machine.communicate.sudo(command)
          else
            logger.info("Not setting #{key}")
          end
        end

        def set_windows_system_proxy(proxy)
          if proxy
            path    = "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings"

            proxy1  = "cmd.exe /C reg add \"#{path}\" /v ProxyEnable   /t REG_DWORD /d 1                          /f"
            proxy2  = "cmd.exe /C reg add \"#{path}\" /v ProxyServer   /t REG_SZ    /d #{config.http.inspect}     /f"
            proxy3  = "cmd.exe /C reg add \"#{path}\" /v ProxyOverride /t REG_SZ    /d #{config.no_proxy.inspect} /f"
            proxy4  = "cmd.exe /C reg add \"#{path}\" /v AutoDetect    /t REG_DWORD /d 0                          /f"

            logger.info('Setting system proxy settings')

            @machine.communicate.sudo(proxy1)
            @machine.communicate.sudo(proxy2)
            @machine.communicate.sudo(proxy3)
            @machine.communicate.sudo(proxy4)
          else
            logger.info("Not setting system proxy settings")
          end
        end

        def windows_guest?
          @machine.config.vm.guest.eql?(:windows)
        end

        def sudo_config
          <<-CONFIG.gsub(/^\s+/, '')
            Defaults env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY"
            Defaults env_keep += "http_proxy https_proxy ftp_proxy no_proxy"
          CONFIG
        end

        def write_environment_config
          tmp = "/tmp/vagrant-proxyconf"
          path = "/etc/environment"

          sed_script = environment_sed_script
          local_tmp = tempfile(environment_config)

          @machine.communicate.tap do |comm|
            comm.sudo("rm -f #{tmp}", error_check: false)
            comm.upload(local_tmp.path, tmp)
            comm.sudo("touch #{path}")
            comm.sudo("sed -e '#{sed_script}' -e '/^$/d' #{path} > #{path}.new")
            comm.sudo("cat #{tmp} >> #{path}.new")
            comm.sudo("chmod 0644 #{path}.new")
            comm.sudo("chown root:root #{path}.new")
            comm.sudo("mv -f #{path}.new #{path}")
            comm.sudo("rm -f #{tmp}")
          end

          true
        end

        def environment_sed_script
          <<-SED.gsub(/^\s+/, '')
            /^HTTP_PROXY=/ d
            /^HTTPS_PROXY=/ d
            /^FTP_PROXY=/ d
            /^NO_PROXY=/ d
            /^http_proxy=/ d
            /^https_proxy=/ d
            /^ftp_proxy=/ d
            /^no_proxy=/ d
          SED
        end

        def environment_config
          return "" if disabled?

          env_config = Hash.new
          env_config["FTP_PROXY"]   = config.ftp if config.ftp
          env_config["HTTP_PROXY"]  = config.http if config.http
          env_config["HTTPS_PROXY"] = config.https if config.https
          env_config["NO_PROXY"]    = config.no_proxy + ',' + @machine.ssh_info[:host] if config.no_proxy

          config_items = env_config.map do |k,v|
            <<-CONFIG.gsub(/^\s+/, '')
              #{k.upcase}="#{v}"
              #{k.downcase}="#{v}"
            CONFIG
          end

          config_items.join("\n")
        end
      end
    end
  end
end
