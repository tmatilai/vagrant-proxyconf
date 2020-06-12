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

          if skip?
            logger.info I18n.t("vagrant_proxyconf.#{config_name}.skip")
            env[:ui].info I18n.t("vagrant_proxyconf.#{config_name}.skip")
          elsif !supported?
            logger.info I18n.t("vagrant_proxyconf.#{config_name}.not_supported")
          elsif disabled?
            logger.info I18n.t("vagrant_proxyconf.#{config_name}.not_enabled")
            env[:ui].info I18n.t("vagrant_proxyconf.#{config_name}.unconfiguring") if supported?
            unconfigure_machine
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

        # Unconfigures the VM, expected to be added to overriden
        def unconfigure_machine
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
            comm.upload(local_tmp.path, tmp)
            if comm.test("command -v sudo")
              comm.sudo("chmod #{opts[:mode] || '0644'} #{tmp}")
              comm.sudo("chown #{opts[:owner] || 'root:root'} #{tmp}")
              comm.sudo("mkdir -p #{File.dirname(path)}")
              comm.sudo("mv -f #{tmp} #{path}")
            else
              raise Vagrant::Errors::CommandUnavailable.new(file: "sudo")
            end
          end
        end

        # @param value [String, nil] the string to escape for shell usage
        def escape(value)
          value.to_s.shellescape
        end

        # @return [Tempfile] a temporary file with the specified content
        def tempfile(content)
          tempfile = Tempfile.new("vagrant-proxyconf")

          begin
            tempfile.tap do |tmp|
              tmp.binmode
              tmp.write(content)
            end
          ensure
            tempfile.close
          end

          tempfile
        end

        def cap_name
          "#{config_name}_conf".to_sym
        end

        def disabled?
          enabled = @machine.config.proxy.enabled
          return true if enabled == false || enabled == ''
          return false if enabled == true

          app_name = config_name.gsub(/_proxy/, '').to_sym

          if enabled.respond_to?(:key)
            return false if enabled.has_key?(app_name) == false

            # if boolean value, return original behavior as mentioned in Readme
            return enabled[app_name] == false if [true, false].include?(enabled[app_name])

            return false if enabled[app_name].has_key?(:skip) == false

            # otherwise assume new behavior using :enabled as a new hash key
            return enabled[app_name][:enabled] == false
          end

          false
        end

        def skip?
          enabled = @machine.config.proxy.enabled
          return true if enabled == false || enabled == ''
          return false if enabled == true

          app_name = config_name.gsub(/_proxy/, '').to_sym

          if enabled.respond_to?(:key)
            return false if enabled.has_key?(app_name) == false

            # if boolean value, return original behavior as mentioned in Readme
            return enabled[app_name] == false if [true, false].include?(enabled[app_name])

            return false if enabled[app_name].has_key?(:skip) == false

            # otherwise assume new behavior using :enabled as a new hash key
            return enabled[app_name][:skip] == true
          end

          false
        end

        def supported?
          @machine.guest.capability?(cap_name) && @machine.guest.capability(cap_name)
        end

        def config_path
          @machine.guest.capability(cap_name)
        end
      end
    end
  end
end
