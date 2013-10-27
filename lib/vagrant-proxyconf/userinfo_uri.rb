require 'uri'

module VagrantPlugins
  module ProxyConf
    # Helper class that strips userinfo from the URI to separate attributes
    class UserinfoURI
      # @return [String] the URI without userinfo
      attr_reader :uri

      alias_method :to_s, :uri

      # @return [String] the username
      attr_reader :user

      # @return [String] the password
      attr_reader :pass

      # @param uri [String] the URI including optional userinfo
      def initialize(uri)
        if uri
          u = URI.parse(uri)
          @uri  = strip_userinfo(u)
          @user = u.user
          @pass = u.password
        end
      end

      private

      # @param uri [URI::Generic] the URI with optional userinfo
      # @return [String] the URI without userinfo
      def strip_userinfo(uri)
        u = uri.dup
        u.userinfo = ''
        u.to_s
      end
    end
  end
end
