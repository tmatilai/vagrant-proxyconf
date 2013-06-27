require 'vagrant'

module VagrantPlugins
  module ProxyConf
    class Plugin < Vagrant.plugin('2')
      name 'vagrant-proxyconf'

      config('apt_proxy') do
        require_relative 'apt_proxy_config'
        AptProxyConfig
      end

      guest_capability 'debian', 'apt_proxy_conf' do
        require_relative 'cap/debian/apt_proxy_conf'
        Cap::Debian::AptProxyConf
      end

      proxyconf_action_hook = lambda do |hook|
        require_relative 'action'
        hook.after Vagrant::Action::Builtin::Provision, Action::ConfigureAptProxy
      end
      action_hook 'proxyconf-machine-up', :machine_action_up, &proxyconf_action_hook
      action_hook 'proxyconf-machine-reload', :machine_action_reload, &proxyconf_action_hook
    end
  end
end
