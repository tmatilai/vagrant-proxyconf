require 'vagrant'

module VagrantPlugins
  module ProxyConf
    # Vagrant Plugin class that registers all proxy configs, hooks, etc.
    #
    # @!parse class Plugin < Vagrant::Plugin::V2::Plugin; end
    class Plugin < Vagrant.plugin('2')
      # The minimum compatible Vagrant version
      MIN_VAGRANT_VERSION = '1.2.0'

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

      def self.register_hooks(hook, provision_action)
        require_relative 'action/configure_apt_proxy'
        require_relative 'action/configure_env_proxy'

        hook.after provision_action, Action::ConfigureAptProxy
        hook.after provision_action, Action::ConfigureEnvProxy
      end

      def self.aws_plugin_installed?
        VagrantPlugins.const_defined?('AWS')
      end

      def self.omnibus_plugin_installed?
        VagrantPlugins.const_defined?('Omnibus')
      end

      setup_i18n
      check_vagrant_version!

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
        if omnibus_plugin_installed?
          # configure the proxies before vagrant-omnibus
          register_hooks(hook, VagrantPlugins::Omnibus::Action::InstallChef)
        else
          register_hooks(hook, Vagrant::Action::Builtin::Provision)

          # vagrant-aws uses a non-standard provision action
          register_hooks(hook, VagrantPlugins::AWS::Action::TimedProvision) if aws_plugin_installed?
        end
      end
    end
  end
end
