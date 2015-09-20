require 'forwardable'
require 'uri'

module VagrantPlugins
  module ProxyConf
    # Helper class that strips userinfo from the URI to separate attributes
    class UserinfoURI
      extend Forwardable

      # @!attribute [r] host
      #   @return [String] the host
      # @!attribute [r] port
      #   @return [String] the port
      def_delegators :@uri, :host, :port

      # @param uri [String] the URI including optional userinfo
      def initialize(uri)
        @set = !!uri
        @uri = URI.parse(uri || '')
      end

      # @return [String] the URI without userinfo
      def uri
        if !@set
          nil
        elsif @uri.to_s.empty?
          ""
        else
          "#{@uri.scheme}://#{host}:#{port}"
        end
      end

      # @return [String] the username
      def user
        return URI.decode(@uri.user) if @uri.user
        @uri.user
      end

      # @return [String] the password
      def pass
        return URI.decode(@uri.password) if @uri.password
        @uri.password
      end

      alias_method :to_s, :uri
    end
  end
end
