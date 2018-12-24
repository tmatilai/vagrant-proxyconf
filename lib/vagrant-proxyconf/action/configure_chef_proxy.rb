require_relative '../logger'
require_relative '../userinfo_uri'
require_relative 'base'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Chef provisioners
      class ConfigureChefProxy < Base

        # Array of Chef provisioner types which include proxy configuration
        CHEF_PROVISIONER_TYPES = [:chef_client, :chef_solo, :chef_zero]

        def config_name
          'chef_proxy'
        end

        private

        def configure_machine
          configure_chef_provisioners
        end

        def unconfigure_machine
          configure_chef_provisioners

          true
        end

        def supported?
          super && !chef_provisioners.empty?
        end

        # @return [Array] all Chef provisioners
        def chef_provisioners
          @machine.config.vm.provisioners.select do |prov|
            # Vagrant 1.7+ uses #type, earlier versions #name
            if prov.respond_to?(:type)
              type = prov.type
            else
              type = prov.name
            end
            CHEF_PROVISIONER_TYPES.include?(type)
          end
        end

        # Configures all Chef provisioner based on the default config
        def configure_chef_provisioners
          chef_provisioners.each { |prov| configure_chef(prov.config) }
        end

        # Configures proxies for a Chef provisioner if they are not set
        #
        # @param chef [VagrantPlugins::Chef::Config::Base] the Chef provisioner configuration
        def configure_chef(chef)
          if disabled?
            logger.info("chef_proxy is not enabled so we should unconfigure it")
            unconfigure_chef_proxy(chef, 'http')
            unconfigure_chef_proxy(chef, 'https')
            return
          end

          logger.info("chef_proxy is enabled so we should configure it")
          configure_chef_proxy(chef, 'http', config.http)
          configure_chef_proxy(chef, 'https', config.https)
          chef.no_proxy ||= config.no_proxy if config.no_proxy
        end

        # @param chef [VagrantPlugins::Chef::Config::Base] the Chef provisioner configuration
        # @param scheme [String] the http protocol (http or https)
        # @param uri [String] the URI with optional userinfo
        def configure_chef_proxy(chef, scheme, uri)
          if uri && !chef.public_send("#{scheme}_proxy") and !disabled?
            u = UserinfoURI.new(uri)
            chef.public_send("#{scheme}_proxy_user=", u.user)
            chef.public_send("#{scheme}_proxy_pass=", u.pass)
            chef.public_send("#{scheme}_proxy=", u.uri)
            logger.info("chef_proxy has been successfully configured")
          end
        end

        # @param chef [VagrantPlugins::Chef::Config::Base] the Chef provisioner configuration
        # @param scheme [String] the http protocol (http or https)
        def unconfigure_chef_proxy(chef, scheme)
          chef.public_send("#{scheme}_proxy_user=", nil)
          chef.public_send("#{scheme}_proxy_pass=", nil)
          chef.public_send("#{scheme}_proxy=", nil)
          chef.no_proxy = nil
          logger.info("chef_proxy has been successfully unconfigured")
        end
      end
    end
  end
end
