require 'vagrant'

module VagrantPlugins
  module ProxyConf
    # Vagrant Plugin class that registers all proxy configs, hooks, etc.
    #
    # @!parse class Plugin < Vagrant::Plugin::V2::Plugin; end
    class Plugin < Vagrant.plugin('2')
      # The minimum compatible Vagrant version
      MIN_VAGRANT_VERSION = '1.2.0'

      # A list of plugins whose action classes we hook to if installed
      OPTIONAL_PLUGIN_DEPENDENCIES = %w[vagrant-aws vagrant-omnibus vagrant-vbguest]

      # Verifies that the Vagrant version fulfills the requirements
      #
      # @raise [VagrantPlugins::ProxyConf::VagrantVersionError] if this plugin
      # is incompatible with the Vagrant version
      def self.check_vagrant_version!
        if Gem::Version.new(Vagrant::VERSION) < Gem::Version.new(MIN_VAGRANT_VERSION)
          msg = I18n.t('vagrant_proxyconf.errors.vagrant_version', min_version: MIN_VAGRANT_VERSION)
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
      # Ignores {Vagrant::Errors::PluginLoadError} but passes other exceptions.
      #
      # @param plugin [String] the plugin name
      def self.load_optional_dependency(plugin)
        begin
          Vagrant.require_plugin plugin
        rescue Vagrant::Errors::PluginLoadError; end
      end

      # Loads the plugins to ensure their action hooks are registered before us.
      # Uses alphabetical order to not change the default behaviour otherwise.
      def self.load_optional_dependencies
        OPTIONAL_PLUGIN_DEPENDENCIES.sort.each { |plugin| load_optional_dependency plugin }
      end

      setup_i18n
      check_vagrant_version!
      load_optional_dependencies

      name 'vagrant-proxyconf'

      config 'apt_proxy' do
        require_relative 'config/apt_proxy'
        Config::AptProxy
      end

      config 'env_proxy' do
        require_relative 'config/env_proxy'
        Config::EnvProxy
      end

      config 'proxy' do
        require_relative 'config/proxy'
        Config::Proxy
      end

      guest_capability 'debian', 'apt_proxy_conf' do
        require_relative 'cap/debian/apt_proxy_conf'
        Cap::Debian::AptProxyConf
      end

      guest_capability 'linux', 'env_proxy_conf' do
        require_relative 'cap/linux/env_proxy_conf'
        Cap::Linux::EnvProxyConf
      end

      action_hook 'proxyconf_configure' do |hook|
        require_relative 'action'

        # the standard provision action
        hook.after Vagrant::Action::Builtin::Provision, Action.configure

        # vagrant-aws < 0.4.0 uses a non-standard provision action
        if defined?(VagrantPlugins::AWS::Action::TimedProvision)
          hook.after VagrantPlugins::AWS::Action::TimedProvision, Action.configure
        end

        # configure the proxies before vagrant-omnibus
        if defined?(VagrantPlugins::Omnibus::Action::InstallChef)
          hook.after VagrantPlugins::Omnibus::Action::InstallChef, Action.configure
        end

        # configure the proxies before vagrant-vbguest
        if defined?(VagrantVbguest::Middleware)
          hook.before VagrantVbguest::Middleware, Action.configure(before: true)
        end
      end
    end
  end
end
