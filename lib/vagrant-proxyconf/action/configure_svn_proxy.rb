require_relative 'base'
require_relative '../userinfo_uri'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Svn on the guest
      class ConfigureSvnProxy < Base
        def config_name
          'svn_proxy'
        end

        private

        def configure_machine
          return if !supported?

          write_config(svn_config, path: '/etc/subversion/servers')

          true
        end

        def unconfigure_machine
          return if !supported?

          @machine.communicate.tap do |comm|
            comm.sudo("touch /etc/subversion/servers")
            comm.sudo("sed -i.bak -e '/^http-proxy-/d' /etc/subversion/servers")
            comm.sudo("chown root:root /etc/subversion/servers")
            comm.sudo("chmod 0644 /etc/subversion/servers")
          end
          true
        end

        def svn_config
          u = UserinfoURI.new(config.http)

          <<-CONFIG.gsub(/^. */, '')
          [global]
          http-proxy-host=#{u.host}
          http-proxy-port=#{u.port}
          http-proxy-username=#{u.user}
          http-proxy-password=#{u.pass}
          http-proxy-exceptions=#{config.no_proxy}
          CONFIG
        end
      end
    end
  end
end
