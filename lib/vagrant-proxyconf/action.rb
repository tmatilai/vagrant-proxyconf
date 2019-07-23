require 'vagrant/action/builtin/call'
require_relative 'action/configure_apt_proxy'
require_relative 'action/configure_chef_proxy'
require_relative 'action/configure_docker_proxy'
require_relative 'action/configure_env_proxy'
require_relative 'action/configure_git_proxy'
require_relative 'action/configure_npm_proxy'
require_relative 'action/configure_pear_proxy'
require_relative 'action/configure_svn_proxy'
require_relative 'action/configure_yum_proxy'
require_relative 'action/is_enabled'
require_relative 'action/only_once'

module VagrantPlugins
  module ProxyConf
    # Middleware stack builders
    class Action
      # Shortcut
      Builtin = Vagrant::Action::Builtin

      # Returns an action middleware stack that configures the VM
      #
      # @param opts [Hash] the options to be passed to {OnlyOnce}
      # @option (see OnlyOnce#initialize)
      def self.configure(opts = {})
        Vagrant::Action::Builder.build(OnlyOnce, opts, &config_actions)
      end

      # Returns an action middleware stack that configures the VM
      # after provisioner runs.
      def self.configure_after_provisoner
        Vagrant::Action::Builder.new.tap do |b|
          b.use Builtin::Call, IsEnabled do |env, b2|
            # next if !env[:result]

            b2.use ConfigureDockerProxy
            b2.use ConfigureGitProxy
            b2.use ConfigureNpmProxy
            b2.use ConfigurePearProxy
            b2.use ConfigureSvnProxy
          end
        end
      end

      private

      # @return [Proc] the block that adds config actions to the specified
      #   middleware builder
      def self.config_actions
        @config_actions ||= Proc.new do |b|
          b.use Builtin::Call, IsEnabled do |env, b2|
            # next if !env[:result]

            # IsEnabled doesn't seem to be quiet right becuse it only seems to check if the proxy has been disabled
            # globally which isn't always what we want. We don't want to skip configuring a service or services
            # because of a disable toggle. Instead we defer to each action class because the implementation for
            # skipping over a service or checking if it is disabled is implmeneted there. To be more clear the real
            # implementation is actually in action/base.rb#call
            b2.use ConfigureAptProxy
            b2.use ConfigureChefProxy
            b2.use ConfigureDockerProxy
            b2.use ConfigureEnvProxy
            b2.use ConfigureGitProxy
            b2.use ConfigureNpmProxy
            b2.use ConfigurePearProxy
            b2.use ConfigureSvnProxy
            b2.use ConfigureYumProxy
          end
        end
      end
    end
  end
end
