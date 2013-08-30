require 'log4r'
require 'tempfile'
require 'vagrant'

module VagrantPlugins
  module ProxyConf
    class Action
      # Base class for proxy configuration Actions
      class Base
        attr_reader :logger

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant::proxyconf')
        end

        def call(env)
          @app.call env

          machine = env[:machine]
          config  = config(machine)

          if !config.enabled?
            logger.debug I18n.t("vagrant_proxyconf.#{config_name}.not_enabled")
          elsif !supported?(machine)
            env[:ui].info I18n.t("vagrant_proxyconf.#{config_name}.not_supported")
          else
            env[:ui].info I18n.t("vagrant_proxyconf.#{config_name}.configuring")
            write_config(machine, config)
          end
        end

        # @return [String] the name of the configuration section
        def config_name
          raise NotImplementedError, "Must be implemented by the inheriting class"
        end

        private

        # @return [Vagrant::Plugin::V2::Config] the configuration
        def config(machine)
          config = machine.config.send(config_name.to_sym)
          finalize_config(config)
          config.merge_defaults(default_config(machine))
        end

        # @return [Vagrant::Plugin::V2::Config] the default configuration
        def default_config(machine)
          config = machine.config.proxy
          finalize_config(config)
        end

        def finalize_config(config)
          # Vagrant pre 1.2.5 does not call `finalize!` if the configuration
          # key is not used in Vagrantfiles.
          # https://github.com/tmatilai/vagrant-proxyconf/issues/2
          config.finalize! if Gem::Version.new(Vagrant::VERSION) < Gem::Version.new('1.2.5')
          config
        end

        def write_config(machine, config)
          logger.debug "Configuration:\n#{config}"

          temp = Tempfile.new("vagrant")
          temp.binmode
          temp.write(config)
          temp.close

          machine.communicate.tap do |comm|
            comm.upload(temp.path, "/tmp/vagrant-proxyconf")
            comm.sudo("cat /tmp/vagrant-proxyconf > #{config_path(machine)}")
            comm.sudo("rm /tmp/vagrant-proxyconf")
          end
        end

        def cap_name
          "#{config_name}_conf".to_sym
        end

        def supported?(machine)
          machine.guest.capability?(cap_name)
        end

        def config_path(machine)
          machine.guest.capability(cap_name)
        end
      end
    end
  end
end
