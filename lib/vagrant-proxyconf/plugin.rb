require 'vagrant'
require_relative 'logger'

module VagrantPlugins
  module ProxyConf
    # Vagrant Plugin class that registers all proxy configs, hooks, etc.
    #
    # @!parse class Plugin < Vagrant::Plugin::V2::Plugin; end
    class Plugin < Vagrant.plugin('2')
      # Compatible Vagrant versions
      VAGRANT_VERSION_REQUIREMENT = '>= 1.2.0'

      # A list of plugins whose action classes we hook to if installed
      OPTIONAL_PLUGIN_DEPENDENCIES = %w[vagrant-aws vagrant-omnibus vagrant-vbguest]

      # Returns true if the Vagrant version fulfills the requirements
      #
      # @param requirements [String, Array<String>] the version requirement
      # @return [Boolean]
      def self.check_vagrant_version(*requirements)
        Gem::Requirement.new(*requirements).satisfied_by?(
          Gem::Version.new(Vagrant::VERSION))
      end

      # Verifies that the Vagrant version fulfills the requirements
      #
      # @raise [VagrantPlugins::ProxyConf::VagrantVersionError] if this plugin
      # is incompatible with the Vagrant version
      def self.check_vagrant_version!
        if !check_vagrant_version(VAGRANT_VERSION_REQUIREMENT)
          msg = I18n.t(
            'vagrant_proxyconf.errors.vagrant_version',
            requirement: VAGRANT_VERSION_REQUIREMENT.inspect)
          $stderr.puts msg
          raise msg
        end
      end

      # Initializes the internationalization strings
      def self.setup_i18n
        I18n.load_path << File.expand_path('../../../locales/en.yml', __FILE__)
        I18n.reload!
      end

      # Ensures a dependent plugin is loaded before us if it is installed.
      # Ignores Errors while loading, as Vagrant itself anyway shows them to
      # user when *it* tries to load the plugin.
      #
      # @param plugin [String] the plugin name
      def self.load_optional_dependency(plugin)
        logger = ProxyConf.logger
        logger.info "Trying to load #{plugin}"

        if check_vagrant_version('< 1.5.0.dev')
          begin
            Vagrant.require_plugin plugin
          rescue Vagrant::Errors::PluginLoadError
            logger.info "Ignoring the load error of #{plugin}"
          end
        else
          begin
            require plugin
          rescue Exception => e
            logger.info "Failed to load #{plugin}: #{e.inspect}"
            logger.info "Ignoring the error"
          end
        end
      end

      # Loads the plugins to ensure their action hooks are registered before us.
      # Uses alphabetical order to not change the default behaviour otherwise.
      def self.load_optional_dependencies
        OPTIONAL_PLUGIN_DEPENDENCIES.sort.each do |plugin|
          load_optional_dependency plugin
        end
      end

      setup_i18n
      check_vagrant_version!
      load_optional_dependencies

      name 'vagrant-proxyconf'
    end
  end
end

require_relative "capability"
require_relative "config"
require_relative "hook"
