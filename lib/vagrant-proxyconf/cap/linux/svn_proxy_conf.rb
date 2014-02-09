module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for Svn command
        module SvnProxyConf
          def self.svn_proxy_conf(machine)
            machine.communicate.test('test -d /etc/subversion')
          end
        end
      end
    end
  end
end
