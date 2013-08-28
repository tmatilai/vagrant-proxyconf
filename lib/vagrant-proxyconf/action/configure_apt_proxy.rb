require 'log4r'
require 'tempfile'
require 'vagrant'

module VagrantPlugins
  module ProxyConf
    class Action
      # Action for configuring Apt on the guest
      class ConfigureAptProxy
        attr_reader :logger

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant::proxyconf::action::configure_apt_proxy')
        end

        def call(env)
          @app.call env

          machine      = env[:machine]
          proxy_config = proxy_config(machine)

          if !proxy_config.enabled?
            logger.debug I18n.t('vagrant_proxyconf.apt_proxy.not_enabled')
          elsif !proxy_conf_capability?(machine)
            env[:ui].info I18n.t('vagrant_proxyconf.apt_proxy.not_supported')
          else
            env[:ui].info I18n.t('vagrant_proxyconf.apt_proxy.configuring')
            write_apt_proxy_conf(machine, proxy_config)
          end
        end

        private

        def proxy_config(machine)
          machine.config.apt_proxy.tap do |config|
            # Vagrant pre 1.2.5 does not call `finalize!` if the configuration
            # key is not used in Vagrantfiles.
            # https://github.com/tmatilai/vagrant-proxyconf/issues/2
            config.finalize! if Gem::Version.new(Vagrant::VERSION) < Gem::Version.new('1.2.5')
          end
        end

        def write_apt_proxy_conf(machine, config)
          logger.debug "Configuration:\n#{config}"

          temp = Tempfile.new("vagrant")
          temp.binmode
          temp.write(config)
          temp.close

          machine.communicate.tap do |comm|
            comm.upload(temp.path, "/tmp/vagrant-apt-proxy-conf")
            comm.sudo("cat /tmp/vagrant-apt-proxy-conf > #{proxy_conf_path(machine)}")
            comm.sudo("rm /tmp/vagrant-apt-proxy-conf")
          end
        end

        def proxy_conf_capability?(machine)
          machine.guest.capability?(:apt_proxy_conf)
        end

        def proxy_conf_path(machine)
          machine.guest.capability(:apt_proxy_conf)
        end
      end
    end
  end
end
