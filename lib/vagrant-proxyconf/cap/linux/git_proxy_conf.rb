module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for Git command
        module GitProxyConf
          def self.git_proxy_conf(machine)
            machine.communicate.test('sudo which git')
          end
        end
      end
    end
  end
end
