require 'tempfile'
require 'vagrant'
require_relative '../logger'

module VagrantPlugins
  module ProxyConf
    class Action
      # Base class for proxy configuration Actions
      class Base
        def initialize(app, env)
          @app = app
        end

        def call(env)
          @machine = env[:machine]

          if !config.enabled?
            logger.info I18n.t("vagrant_proxyconf.#{config_name}.not_enabled")
          elsif !supported?
            logger.info I18n.t("vagrant_proxyconf.#{config_name}.not_supported")
          else
            env[:ui].info I18n.t("vagrant_proxyconf.#{config_name}.configuring")
            configure_machine
          end

          @app.call env
        end

        # @return [String] the name of the configuration section
        def config_name
          raise NotImplementedError, "Must be implemented by the inheriting class"
        end

        private

        # @return [Log4r::Logger]
        def logger
          ProxyConf.logger
        end

        # @return [Vagrant::Plugin::V2::Config] the configuration
        def config
          return @config if @config

          config = @machine.config.public_send(config_name.to_sym)
          finalize_config(config)
          @config = config.merge_defaults(default_config)
        end

        # @return [Vagrant::Plugin::V2::Config] the default configuration
        def default_config
          config = @machine.config.proxy
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
        def configure_machine
          write_config(config)
        end

        # Writes the config to the VM
        #
        # @param opts [Hash] optional file options
        # @option opts [String] :path (#config_path) the path of the configuration file
        # @option opts [String] :mode ("0644") the mode of the file
        # @option opts [String] :owner ("root:root") the owner (and group) of the file
        def write_config(config, opts = {})
          tmp = "/tmp/vagrant-proxyconf"
          path = opts[:path] || config_path
          local_tmp = tempfile(config)

          logger.debug "Configuration (#{path}):\n#{config}"
          @machine.communicate.tap do |comm|
            comm.sudo("rm #{tmp}", error_check: false)
            comm.upload(local_tmp.path, tmp)
            comm.sudo("chmod #{opts[:mode] || '0644'} #{tmp}")
            comm.sudo("chown #{opts[:owner] || 'root:root'} #{tmp}")
            comm.sudo("mkdir -p #{File.dirname(path)}")

            if opts[:append]
              comm.sudo("cat #{tmp} | tee -a #{path}")
            else
              comm.sudo("mv #{tmp} #{path}")
            end
          end
        end

        # @param value [String, nil] the string to escape for shell usage
        def escape(value)
          value.to_s.shellescape
        end

        # @return [Tempfile] a temporary file with the specified content
        def tempfile(content)
          Tempfile.new("vagrant").tap do |temp|
            temp.binmode
            temp.write(content)
            temp.close
          end
        end

        def cap_name
          "#{config_name}_conf".to_sym
        end

        def supported?
          @machine.guest.capability?(cap_name) &&
            @machine.guest.capability(cap_name)
        end

        def config_path
          @machine.guest.capability(cap_name)
        end

        # @param value [String, nil] the string to escape for shell usage
        def escape(value)
          value.to_s.shellescape
        end
      end
    end
  end
end
