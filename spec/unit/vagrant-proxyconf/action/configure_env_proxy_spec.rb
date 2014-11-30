require 'spec_helper'
require 'vagrant-proxyconf/action/configure_env_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureEnvProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { is_expected.to eq 'env_proxy' }
  end

  describe '#disabled?' do
    subject do
      conf = described_class.new(double, double)
      allow(conf).to receive_message_chain(:config, :enabled?)
        .and_return(@config_enabled)
      machine = double('machine')
      allow(machine).to receive_message_chain(:config, :proxy, :enabled)
        .and_return(@config_proxy_enabled)
      conf.instance_variable_set(:@machine, machine)
      conf.send(:disabled?)
    end

    context 'when both config and proxy are enabled' do
      it do
        @config_enabled = true
        @config_proxy_enabled = true
        is_expected.to eq false
      end
    end
    context 'when config is enabled and config proxy is not enabled' do
      it do
        @config_enabled = true
        @config_proxy_enabled = false
        is_expected.to eq true
      end
    end
    context 'when config is enabled and config proxy is empty string' do
      it do
        @config_enabled = true
        @config_proxy_enabled = ''
        is_expected.to eq true
      end
    end
    context 'when config is not enabled and proxy is enabled' do
      it do
        @config_enabled = false
        @config_proxy_enabled = true
        is_expected.to eq true
      end
    end

    context 'when both config and target proxy are enabled' do
      it do
        @config_enabled = true
        @config_proxy_enabled = { env: true }
        is_expected.to eq false
      end
    end
    context 'when config is enabled and target proxy target is not enabled' do
      it do
        @config_enabled = true
        @config_proxy_enabled = { env: false }
        is_expected.to eq true
      end
    end
    context 'when config is enabled and other proxy are not enabled' do
      it do
        @config_enabled = true
        @config_proxy_enabled = {
          svn: false,
          apt: false,
          chef: false,
          docker: false,
          git: false,
          npm: false,
          pear: false,
          svn: false,
          yum: false
        }
        is_expected.to eq false
      end

    end
  end
end
