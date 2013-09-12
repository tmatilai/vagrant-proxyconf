module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Chef provisioners
      class ConfigureChefProxy
        attr_reader :logger

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant::proxyconf')
        end

        def call(env)
          @app.call env

          machine = env[:machine]
          config  = config(machine)

          if chef_provisioners(machine).empty?
            logger.debug I18n.t("vagrant_proxyconf.chef_proxy.no_provisioners")
          elsif !config.enabled?
            logger.debug I18n.t("vagrant_proxyconf.chef_proxy.not_enabled")
          else
            env[:ui].info I18n.t("vagrant_proxyconf.chef_proxy.configuring")
            configure_chef_provisioners(machine, config)
          end
        end

        private

        # @return [Config::Proxy] the `config.proxy` configuration
        def config(machine)
          config = machine.config.proxy
          config.finalize! if Gem::Version.new(Vagrant::VERSION) < Gem::Version.new('1.2.5')
          config
        end

        # @return [Array] all Chef provisioners
        def chef_provisioners(machine)
          machine.config.vm.provisioners.select { |prov| [:chef_solo, :chef_client].include?(prov.name) }
        end

        # Configures all Chef provisioner based on the default config
        #
        # @param config [Config::Proxy] the default configuration
        def configure_chef_provisioners(machine, config)
          chef_provisioners(machine).each { |prov| configure_chef(prov.config, config) }
        end

        # Configures proxies for the Chef provisioner if they are not set
        #
        # @param chef [VagrantPlugins::Chef::Config::Base] the Chef provisioner configuration
        # @param config [Config::Proxy] the default configuration
        def configure_chef(chef, config)
          if !chef.http_proxy && config.http
            chef.http_proxy      = config.http
            chef.http_proxy_user = config.http_user
            chef.http_proxy_pass = config.http_pass
          end
          if !chef.https_proxy && config.https
            chef.https_proxy      = config.https
            chef.https_proxy_user = config.https_user
            chef.https_proxy_pass = config.https_pass
          end
          if !chef.no_proxy && config.no_proxy
            chef.no_proxy = config.no_proxy
          end
        end
      end
    end
  end
end
