module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for Svn command
        module SvnProxyConf
          def self.svn_proxy_conf(machine)
            machine.communicate.test('which svn')
          end
        end
      end
    end
  end
end
