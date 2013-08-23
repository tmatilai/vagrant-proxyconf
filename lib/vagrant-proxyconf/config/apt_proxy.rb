require 'vagrant'

module VagrantPlugins
  module ProxyConf
    module Config
      # Proxy configuration for Apt
      #
      # @!parse class AptProxy < Vagrant::Plugin::V2::Config; end
      class AptProxy < Vagrant.plugin('2', :config)
        # @return [String] the HTTP proxy
        attr_accessor :http

        # @return [String] the HTTPS proxy
        attr_accessor :https

        # @return [String] the FTP proxy
        attr_accessor :ftp

        def initialize
          @http  = UNSET_VALUE
          @https = UNSET_VALUE
          @ftp   = UNSET_VALUE
        end

        def finalize!
          @http = override_from_env_var('http', @http)
          @http = nil if @http == UNSET_VALUE

          @https = override_from_env_var('https', @https)
          @https = nil if @https == UNSET_VALUE

          @ftp = override_from_env_var('ftp', @ftp)
          @ftp = nil if @ftp == UNSET_VALUE
        end

        def enabled?
          !http.nil? || !https.nil? || !ftp.nil?
        end

        # @return [String] the full configuration stanza
        def to_s
          %w[http https ftp].map { |proto| config_for(proto) }.join
        end

        private

        def override_from_env_var(proto, default)
          ENV.fetch("VAGRANT_APT_#{proto.upcase}_PROXY", default)
        end

        def config_for(proto)
          ConfigLine.new(proto, send(proto.to_sym))
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
            set? ? %Q{Acquire::#{proto}::Proxy "#{direct || proxy_uri}";\n} : ""
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
