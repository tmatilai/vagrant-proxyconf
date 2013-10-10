require_relative 'action/configure_apt_proxy'
require_relative 'action/configure_chef_proxy'
require_relative 'action/configure_env_proxy'
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
          builder.use ConfigureAptProxy
          builder.use ConfigureChefProxy
          builder.use ConfigureEnvProxy
        end
      end
    end
  end
end
