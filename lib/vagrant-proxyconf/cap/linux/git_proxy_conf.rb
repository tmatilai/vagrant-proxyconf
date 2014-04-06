require_relative '../util'

module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for git proxy configuration
        module GitProxyConf
          # @return [String, false] the path to git or `false` if not found
          def self.git_proxy_conf(machine)
            Util.which(machine, 'git')
          end
        end
      end
    end
  end
end
