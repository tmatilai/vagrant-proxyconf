require 'vagrant'
require_relative 'key_mixin'

module VagrantPlugins
  module ProxyConf
    module Config
      # Proxy configuration for Apt
      #
      # @!parse class AptProxy < Vagrant::Plugin::V2::Config; end
      class AptProxy < Vagrant.plugin('2', :config)
        include KeyMixin
        # @!parse extend KeyMixin::ClassMethods

        # @return [String] the HTTP proxy
        key :http, env_var: 'VAGRANT_APT_HTTP_PROXY'

        # @return [String] the HTTPS proxy
        key :https, env_var: 'VAGRANT_APT_HTTPS_PROXY'

        # @return [String] the FTP proxy
        key :ftp, env_var: 'VAGRANT_APT_FTP_PROXY'

        private

        # (see KeyMixin#config_for)
        def config_for(key, value)
          ConfigLine.new(key.name, value)
        end

        # Helper for constructing a configuration line for apt.conf
        #
        # @api private
        class ConfigLine

          attr_reader :proto, :value

          # @param proto [String] the protocol ("http", "https", ...)
          # @param value [Object] the configuration value
          def initialize(proto, value)
            @proto = proto
            @value = value
          end

          # @return [String] the full Apt configuration line
          def to_s
            %Q{Acquire::#{proto}::Proxy "#{direct || proxy_uri}";\n} if set?
          end

          private

          def set?
            value && !value.empty?
          end

          def direct
            "DIRECT" if value.upcase == "DIRECT"
          end

          def proxy_uri
            "#{prefix}#{value}#{suffix}"
          end

          def prefix
            "#{proto}://" if value !~ %r{^.*://}
          end

          def suffix
            ":#{default_port}" if value !~ %r{:\d+$} && value !~ %r{/}
          end

          def default_port
            3142
          end
        end
      end
    end
  end
end
