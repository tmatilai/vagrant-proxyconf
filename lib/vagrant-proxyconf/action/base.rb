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
            configure_machine(machine, config)
          end
        end

        # @return [String] the name of the configuration section
        def config_name
          raise NotImplementedError, "Must be implemented by the inheriting class"
        end

        private

        # @return [Vagrant::Plugin::V2::Config] the configuration
        def config(machine)
          config = machine.config.public_send(config_name.to_sym)
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

        # Configures the VM based on the config
        def configure_machine(machine, config)
          write_config(machine, config)
        end

        # Writes the config to the VM
        #
        # @param opts [Hash] optional file options
        # @option opts [String] :path (#config_path) the path of the configuration file
        # @option opts [String] :mode the mode of the file
        def write_config(machine, config, opts = {})
          path = opts[:path] || config_path(machine)
          logger.debug "Configuration (#{path}):\n#{config}"

          temp = Tempfile.new("vagrant")
          temp.binmode
          temp.write(config)
          temp.close

          machine.communicate.tap do |comm|
            comm.upload(temp.path, "/tmp/vagrant-proxyconf")
            comm.sudo("mkdir -p #{File.dirname(path)}")
            comm.sudo("cat /tmp/vagrant-proxyconf > #{path}")
            comm.sudo("chmod #{opts[:mode]} #{path}") if opts[:mode]
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
