require 'vagrant'

module VagrantPlugins
  module ProxyConf
    class Plugin < Vagrant.plugin('2')
      # Actions to run before any provisioner or other plugin
      action_hook 'proxyconf_configure' do |hook|
        require_relative 'action'

        # the standard provision action
        hook.after Vagrant::Action::Builtin::Provision, Action.configure

        # Vagrant 1.5+ can install NFS client
        if check_vagrant_version('>= 1.5.0.dev')
          hook.after Vagrant::Action::Builtin::SyncedFolders, Action.configure
        end

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

      # Actions to run after each provisioner run
      action_hook 'proxyconf_configure', :provisioner_run do |hook|
        require_relative 'action'
        hook.after :run_provisioner, Action.configure_after_provisoner
      end
    end
  end
end
