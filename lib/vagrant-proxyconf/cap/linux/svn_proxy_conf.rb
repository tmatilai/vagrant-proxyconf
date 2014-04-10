require_relative '../util'

module VagrantPlugins
  module ProxyConf
    module Cap
      module Linux
        # Capability for svn proxy configuration
        module SvnProxyConf
          # @return [String, false] the path to svn or `false` if not found
          def self.svn_proxy_conf(machine)
            Util.which(machine, 'svn')
          end
        end
      end
    end
  end
end
