require_relative 'base'
require_relative '../resource'
require_relative '../userinfo_uri'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Yum on the guest
      class ConfigureYumProxy < Base
        def config_name
          'yum_proxy'
        end

        private

        def configure_machine
          return if !supported?

          tmp = "/tmp/vagrant-proxyconf"
          path = config_path

          @machine.communicate.tap do |comm|
            comm.sudo("rm -f #{tmp}", error_check: false)
            comm.upload(ProxyConf.resource("yum_config.awk"), tmp)
            comm.sudo("touch #{path}")
            comm.sudo("gawk -i inplace -f #{tmp} #{proxy_params} `realpath #{path}`")
            comm.sudo("rm -f #{tmp}")
          end

          true
        end

        def unconfigure_machine
          return if !supported?

          @machine.communicate.tap do |comm|
            if comm.test("grep '^proxy' #{config_path}")
              comm.sudo("sed -i.bak -e '/^proxy/d' `realpath #{config_path}`")
            end
          end

          true
        end

        def proxy_params
          u = UserinfoURI.new(config.http)
          "-v proxy=#{escape(u.uri)} -v user=#{escape(u.user)} -v pass=#{escape(u.pass)}"
        end
      end
    end
  end
end
