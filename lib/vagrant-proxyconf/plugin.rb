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
        require_relative 'action'

        if defined? VagrantPlugins::Omnibus::Action::InstallChef
          # configure the proxies before vagrant-omnibus
          hook.after VagrantPlugins::Omnibus::Action::InstallChef, Action.configure
        else
          hook.after Vagrant::Action::Builtin::Provision, Action.configure

          # vagrant-aws < 0.4.0 uses a non-standard provision action
          if defined? VagrantPlugins::AWS::Action::TimedProvision
            hook.after VagrantPlugins::AWS::Action::TimedProvision, Action.configure
          end
        end
      end
    end
  end
end
