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
            direct || "#{prefix}#{value}#{suffix}"
          end

          private

          def direct
            'DIRECT' if value.upcase == 'DIRECT'
          end

          def prefix
            "#{scheme}://" if value !~ %r{^.*://}
          end

          def suffix
            ':3142' if value !~ %r{:\d+$} && value !~ %r{/}
          end
        end
      end
    end
  end
end
