require_relative 'base'
require_relative '../resource'
require_relative '../userinfo_uri'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring systemd on the guest
      class ConfigureSystemdProxy < Base
        TMP_PATH = '/tmp/vagrant-proxyconf'
        CONFIG_REGEXP = '^DefaultEnvironment.*#vagrant-proxyconf'
        I18N_PREFIX = 'vagrant_proxyconf.systemd_proxy.'

        def config_name
          'systemd_proxy'
        end

        private

        def config
          # Use global proxy config
          @config ||= finalize_config(@machine.config.proxy)
        end

        def configure_machine
          logger.info('Writing the proxy configuration to systemd config')
          write_systemd_config
          reflect_config
        end

        def write_systemd_config
          env_config =
            "DefaultEnvironment=#{systemd_env_settings} #vagrant-proxyconf"

          @machine.communicate.tap do |comm|
            comm.sudo("cp -p #{config_path} #{TMP_PATH}", error_check: false)
            comm.sudo("grep -ve '#{CONFIG_REGEXP}' #{config_path} > #{TMP_PATH}")
            comm.sudo("echo -e '#{env_config}' >> #{TMP_PATH}")
            @restart_needed = !comm.test("diff -w #{TMP_PATH} #{config_path}")
            comm.sudo("mv '#{TMP_PATH}' #{config_path}")
          end
        end

        def reflect_config
          return unless @restart_needed
          @machine.ui.info(I18n.t("#{I18N_PREFIX}restarting_guest_start"))
          begin timeout(10) { @machine.communicate.sudo('shutdown -r now') }
          rescue Timeout::Error
            logger.info('shutdown -r now was called but timeout')
          end

          sleep 5 until @machine.communicate.ready?
          @machine.ui.info(I18n.t("#{I18N_PREFIX}restarting_guest_done"))
        end

        def systemd_env_settings
          https_proxy = config.https    || ''
          http_proxy  = config.http     || ''
          ftp_proxy   = config.ftp      || ''
          no_proxy    = config.no_proxy || ''
          ["HTTPS_PROXY=#{https_proxy}",
            "HTTP_PROXY=#{http_proxy}",
            "FTP_PROXY=#{ftp_proxy}",
            "NO_PROXY=#{no_proxy}",
            "https_proxy=#{https_proxy}",
            "http_proxy=#{http_proxy}",
            "ftp_proxy=#{ftp_proxy}",
            "no_proxy=#{no_proxy}"].join(' ')
        end
      end
    end
  end
end
