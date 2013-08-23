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
          msg = "vagrant-proxyconf plugin requires Vagrant #{MIN_VAGRANT_VERSION} or newer"
          $stderr.puts msg
          raise msg
        end
      end

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

      guest_capability 'debian', 'apt_proxy_conf' do
        require_relative 'cap/debian/apt_proxy_conf'
        Cap::Debian::AptProxyConf
      end

      guest_capability 'linux', 'env_proxy_conf' do
        require_relative 'cap/linux/env_proxy_conf'
        Cap::Linux::EnvProxyConf
      end

      action_hook 'proxyconf_configure' do |hook|
        require_relative 'action/configure_apt_proxy'
        require_relative 'action/configure_env_proxy'

        hook.after Vagrant::Action::Builtin::Provision, Action::ConfigureAptProxy
        hook.after Vagrant::Action::Builtin::Provision, Action::ConfigureEnvProxy

        # vagrant-aws uses a non-standard provision action
        if VagrantPlugins.const_defined?('AWS')
          hook.after VagrantPlugins::AWS::Action::TimedProvision, Action::ConfigureAptProxy
          hook.after VagrantPlugins::AWS::Action::TimedProvision, Action::ConfigureEnvProxy
        end
      end
    end
  end
end
