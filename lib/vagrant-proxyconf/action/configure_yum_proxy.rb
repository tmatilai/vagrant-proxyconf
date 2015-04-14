require_relative 'base'
require_relative '../resource'
require_relative '../userinfo_uri'
require 'uri'

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
          tmp = "/tmp/vagrant-proxyconf"
          path = config_path

          @machine.communicate.tap do |comm|
            comm.sudo("rm -f #{tmp}", error_check: false)
            comm.upload(ProxyConf.resource("yum_config.awk"), tmp)
            comm.sudo("touch #{path}")
            comm.sudo("gawk -f #{tmp} #{proxy_params} #{path} > #{path}.new")
            comm.sudo("chmod 0644 #{path}.new")
            comm.sudo("chown root:root #{path}.new")
            comm.sudo("mv -f #{path}.new #{path}")
            comm.sudo("rm -f #{tmp}")
          end
        end

        def proxy_params
          u = UserinfoURI.new(config.http)
          if !u.pass.nil?
            pdecode = URI.decode(u.pass)
          else
            pdecode = u.pass
          end

          "-v proxy=#{escape(u.uri)} -v user=#{escape(u.user)} -v pass=#{escape(pdecode)}"
        end
      end
    end
  end
end
