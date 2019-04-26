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

        # @return [String] whether APT should verify peer certificate
        key :verify_peer, env_var: 'VAGRANT_APT_VERIFY_PEER'

        # @return [String] whether APT should verify that certificate name matches server name
        key :verify_host, env_var: 'VAGRANT_APT_VERIFY_HOST'

        def finalize!
          super

          keys.each do |key|
            value = get(key)
            set(key, finalize_uri(key, value)) if value
          end
        end

        private

        # (see KeyMixin#config_for)
        def config_for(key, value)
          %Q{Acquire::#{key.name}::Proxy #{value.inspect};\n} if value
        end

        def finalize_uri(key, value)
          AptProxyURI.new(key.name, value).to_s
        end

        # Helper for constructing configuration values for apt.conf
        #
        # @api private
        class AptProxyURI

          attr_reader :scheme, :value

          # @param scheme [String] the protocol ("http", "https", ...)
          # @param value [Object] the configuration value
          def initialize(scheme, value)
            @scheme = scheme
            @value = value
          end

          def to_s
            direct || verify || "#{prefix}#{value}#{suffix}"
          end

          private

          def direct
            'DIRECT' if value.upcase == 'DIRECT'
          end

          def verify
            value if ["true", "false"].to_set.contains? value
          end

          # Hash of deprecation warning sentinels
          @@warned = {}

          def prefix
            if value !~ %r{^.*://}
              if !@@warned[:scheme]
                @@warned[:scheme] = true

                puts 'DEPRECATION: Specifying the scheme (http://) for `apt_proxy` URIs'
                puts 'will be mandatory in v2.0.0.'
                puts
              end

              "#{scheme}://"
            end
          end

          def suffix
            if value !~ %r{:\d+$} && value !~ %r{/}
              if !@@warned[:port]
                @@warned[:port] = true

                puts 'DEPRECATION: Please specify the port (3142) for `apt_proxy` URIs,'
                puts 'as the default will change in v2.0.0.'
                puts
              end

              ':3142'
            end
          end
        end
      end
    end
  end
end
