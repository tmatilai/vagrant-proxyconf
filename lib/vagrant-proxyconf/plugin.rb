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

      guest_capability 'debian', 'apt_proxy_conf' do
        require_relative 'cap/debian/apt_proxy_conf'
        Cap::Debian::AptProxyConf
      end

      proxyconf_action_hook = lambda do |hook|
        require_relative 'action/configure_apt_proxy'
        hook.after Vagrant::Action::Builtin::Provision, Action::ConfigureAptProxy

        # vagrant-aws uses a non-standard provision action
        if VagrantPlugins.const_defined?('AWS')
          hook.after VagrantPlugins::AWS::Action::TimedProvision, Action::ConfigureAptProxy
        end
      end
      action_hook 'proxyconf-machine-up', :machine_action_up, &proxyconf_action_hook
      action_hook 'proxyconf-machine-reload', :machine_action_reload, &proxyconf_action_hook
      # Hook to vagrant-digitalocean's `rebuild` command
      action_hook 'proxyconf-machine-rebuild', :machine_action_rebuild, &proxyconf_action_hook
    end
  end
end
