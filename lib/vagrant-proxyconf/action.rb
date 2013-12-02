require 'vagrant/action/builtin/call'
require_relative 'action/configure_apt_proxy'
require_relative 'action/configure_chef_proxy'
require_relative 'action/configure_env_proxy'
require_relative 'action/configure_yum_proxy'
require_relative 'action/is_enabled'
require_relative 'action/only_once'

module VagrantPlugins
  module ProxyConf
    # Middleware stack builders
    class Action
      # Returns an action middleware stack that configures the VM
      #
      # @param opts [Hash] the options to be passed to {OnlyOnce}
      # @option (see OnlyOnce#initialize)
      def self.configure(opts = {})
        Vagrant::Action::Builder.build(OnlyOnce, opts, &config_actions)
      end

      private

      # @return [Proc] the block that adds config actions to the specified
      #   middleware builder
      def self.config_actions
        @actions ||= Proc.new do |builder|
          builder.use Vagrant::Action::Builtin::Call, IsEnabled do |env, b2|
            next if !env[:result]

            b2.use ConfigureAptProxy
            b2.use ConfigureChefProxy
            b2.use ConfigureEnvProxy
            b2.use ConfigureYumProxy
          end
        end
      end
    end
  end
end
