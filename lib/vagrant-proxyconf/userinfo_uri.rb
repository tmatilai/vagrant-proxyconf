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
      # @!attribute [r] user
      #   @return [String] the username
      def_delegators :@uri, :host, :port, :user

      # @!attribute [r] pass
      #   @return [String] the password
      def_delegator :@uri, :password, :pass

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

      alias_method :to_s, :uri
    end
  end
end
