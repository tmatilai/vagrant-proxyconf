require_relative 'action/configure_apt_proxy'
require_relative 'action/configure_chef_proxy'
require_relative 'action/configure_env_proxy'

module VagrantPlugins
  module ProxyConf
    # Middleware stack builders
    class Action
      # Returns an action middleware stack that configures the VM
      def self.configure
        @configure ||= Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigureEnvProxy
          b.use ConfigureChefProxy
          b.use ConfigureAptProxy
        end
      end
    end
  end
end
