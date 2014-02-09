require 'vagrant'
require_relative 'logger'

module VagrantPlugins
  module ProxyConf
    # Vagrant Plugin class that registers all proxy configs, hooks, etc.
    #
    # @!parse class Plugin < Vagrant::Plugin::V2::Plugin; end
    class Plugin < Vagrant.plugin('2')
      # Compatible Vagrant versions
      VAGRANT_VERSION_REQUIREMENT = '>= 1.2.0'

      # A list of plugins whose action classes we hook to if installed
      OPTIONAL_PLUGIN_DEPENDENCIES = %w[vagrant-aws vagrant-omnibus vagrant-vbguest]

      # Returns true if the Vagrant version fulfills the requirements
      #
      # @param requirements [String, Array<String>] the version requirement
      # @return [Boolean]
      def self.check_vagrant_version(*requirements)
        Gem::Requirement.new(*requirements).satisfied_by?(
          Gem::Version.new(Vagrant::VERSION))
      end

      # Verifies that the Vagrant version fulfills the requirements
      #
      # @raise [VagrantPlugins::ProxyConf::VagrantVersionError] if this plugin
      # is incompatible with the Vagrant version
      def self.check_vagrant_version!
        if !check_vagrant_version(VAGRANT_VERSION_REQUIREMENT)
          msg = I18n.t(
            'vagrant_proxyconf.errors.vagrant_version',
            requirement: VAGRANT_VERSION_REQUIREMENT.inspect)
          $stderr.puts msg
          raise msg
        end
      end

      # Initializes the internationalization strings
      def self.setup_i18n
        I18n.load_path << File.expand_path('../../../locales/en.yml', __FILE__)
        I18n.reload!
      end

      # Ensures a dependent plugin is loaded before us if it is installed.
      # Ignores Errors while loading, as Vagrant itself anyway shows them to
      # used when *it* tries to load the plugin.
      #
      # @param plugin [String] the plugin name
      def self.load_optional_dependency(plugin)
        logger = ProxyConf.logger
        logger.info "Trying to load #{plugin}"

        if check_vagrant_version('< 1.5.0.dev')
          begin
            Vagrant.require_plugin plugin
          rescue Vagrant::Errors::PluginLoadError
            logger.info "Ignoring the load error of #{plugin}"
          end
        else
          begin
            require plugin
          rescue Exception => e
            logger.info "Failed to load #{plugin}: #{e.inspect}"
            logger.info "Ignoring the error"
          end
        end
      end

      # Loads the plugins to ensure their action hooks are registered before us.
      # Uses alphabetical order to not change the default behaviour otherwise.
      def self.load_optional_dependencies
        OPTIONAL_PLUGIN_DEPENDENCIES.sort.each do |plugin|
          load_optional_dependency plugin
        end
      end

      setup_i18n
      check_vagrant_version!
      load_optional_dependencies

      name 'vagrant-proxyconf'

      config 'apt_proxy' do
        require_relative 'config/apt_proxy'
        Config::AptProxy
      end

      config 'env_proxy' do
        require_relative 'config/env_proxy'
        Config::EnvProxy
      end

      config 'git_proxy' do
        require_relative 'config/git_proxy'
        Config::GitProxy
      end

      config 'svn_proxy' do
        require_relative 'config/svn_proxy'
        Config::SvnProxy
      end

      config 'proxy' do
        require_relative 'config/proxy'
        Config::Proxy
      end

      config 'yum_proxy' do
        require_relative 'config/yum_proxy'
        Config::YumProxy
      end

      guest_capability 'debian', 'apt_proxy_conf' do
        require_relative 'cap/debian/apt_proxy_conf'
        Cap::Debian::AptProxyConf
      end

      guest_capability 'linux', 'env_proxy_conf' do
        require_relative 'cap/linux/env_proxy_conf'
        Cap::Linux::EnvProxyConf
      end

      guest_capability 'linux', 'pear_proxy_conf' do
        require_relative 'cap/linux/pear_proxy_conf'
        Cap::Linux::PearProxyConf
      end

      guest_capability 'linux', 'git_proxy_conf' do
        require_relative 'cap/linux/git_proxy_conf'
        Cap::Linux::GitProxyConf
      end

      guest_capability 'linux', 'svn_proxy_conf' do
        require_relative 'cap/linux/svn_proxy_conf'
        Cap::Linux::SvnProxyConf
      end

      guest_capability 'coreos', 'env_proxy_conf' do
        # disabled on CoreOS
      end

      guest_capability 'redhat', 'yum_proxy_conf' do
        require_relative 'cap/redhat/yum_proxy_conf'
        Cap::Redhat::YumProxyConf
      end

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

      action_hook 'proxyconf_configure', :provisioner_run do |hook|
        require_relative 'action'
        hook.append Action.configure_after_provisoner
      end
    end
  end
end

require_relative "capability"
require_relative "config"
require_relative "hook"
