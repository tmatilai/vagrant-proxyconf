require 'spec_helper'
require 'vagrant-proxyconf/plugin'

describe VagrantPlugins::ProxyConf::Plugin do

  describe '.check_vagrant_version' do
    before :each do
      stub_const('Vagrant::VERSION', '1.2.3')
    end

    it "accepts single String argument" do
      expect(described_class.check_vagrant_version('~> 1.1')).to be_truthy
      expect(described_class.check_vagrant_version('1.2')).to be_falsey
    end

    it "accepts an Array argument" do
      expect(described_class.check_vagrant_version(['>= 1.1', '< 1.3.0.beta'])).to be_truthy
      expect(described_class.check_vagrant_version(['>= 1.3'])).to be_falsey
    end

    it "accepts multiple arguments" do
      expect(described_class.check_vagrant_version('>= 1.0', '<= 1.3')).to be_truthy
      expect(described_class.check_vagrant_version('~> 1.2', '>= 1.2.5')).to be_falsey
    end
  end

  describe '.check_vagrant_version!' do
    subject { described_class.check_vagrant_version! }
    let(:requirement) { '>= 1.2.3' }
    let(:err_msg) { /requires Vagrant version #{Regexp.escape(requirement.inspect)}/ }

    before :each do
      stub_const(
        'VagrantPlugins::ProxyConf::Plugin::VAGRANT_VERSION_REQUIREMENT',
        requirement)
      stub_const('Vagrant::VERSION', vagrant_version)
      allow($stderr).to receive(:puts)
    end

    context "on too old Vagrant version" do
      let(:vagrant_version) { '1.1.5' }
      it "raises" do
        expect { subject }.to raise_error(err_msg)
      end
      it "warns" do
        expect($stderr).to receive(:puts).with(err_msg)
        subject rescue nil
      end
    end

    context "on exact required Vagrant version" do
      let(:vagrant_version) { '1.2.3' }
      it "does not raise" do
        expect { subject }.not_to raise_error
      end
    end

    context "on newer Vagrant version" do
      let(:vagrant_version) { '1.3.5' }
      it "does not raise" do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe '.load_optional_dependency' do
    subject { described_class.load_optional_dependency(plugin_name) }
    let(:plugin_name) { 'vagrant-foo' }

    # Vagrant plugin loading API changed in v1.5.0
    if Gem::Version.new(Vagrant::VERSION) < Gem::Version.new('1.5.0.dev')
      it "loads the specified plugin" do
        expect(Vagrant).to receive(:require_plugin).with(plugin_name)
        subject
      end

      it "ignores PluginLoadError" do
        expect(Vagrant).to receive(:require_plugin).
          and_raise(Vagrant::Errors::PluginLoadError, plugin: plugin_name)
        expect { subject }.not_to raise_error
      end

      it "won't ignore other error" do
        expect(Vagrant).to receive(:require_plugin).
          and_raise(Vagrant::Errors::PluginLoadFailed, plugin: plugin_name)
        expect { subject }.to raise_error(Vagrant::Errors::PluginLoadFailed)
      end
    else
      it "loads the specified plugin" do
        expect(described_class).to receive(:require).with(plugin_name)
        subject
      end

      it "ignores errors" do
        expect(described_class).to receive(:require).
          and_raise(LoadError, path: plugin_name)
        expect { subject }.not_to raise_error
      end
    end
  end

  describe '.load_optional_dependencies' do
    let(:plugins) { %w[vagrant-foo vagrant-bar vagrant-baz] }
    let(:loaded_plugins) { [] }

    it "loads the plugins in alphabetical order" do
      stub_const('VagrantPlugins::ProxyConf::Plugin::OPTIONAL_PLUGIN_DEPENDENCIES', plugins)
      allow(described_class).to receive(:load_optional_dependency) { |plugin| loaded_plugins << plugin }
      described_class.load_optional_dependencies
      expect(loaded_plugins).to eq %w[vagrant-bar vagrant-baz vagrant-foo]
    end
  end
end
