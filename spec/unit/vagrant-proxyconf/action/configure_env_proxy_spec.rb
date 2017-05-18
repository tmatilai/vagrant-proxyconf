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
      machine = double('machine')
      allow(machine).to receive_message_chain(:config, :proxy, :enabled)
        .and_return(@config_proxy_enabled)
      conf.instance_variable_set(:@machine, machine)
      conf.send(:disabled?)
    end

    context 'when config proxy is enabled' do
      it do
        @config_proxy_enabled = true
        is_expected.to eq false
      end
    end
    context 'when config proxy is not enabled' do
      it do
        @config_proxy_enabled = false
        is_expected.to eq true
      end
    end
    context 'when config proxy is empty string' do
      it do
        @config_proxy_enabled = ''
        is_expected.to eq true
      end
    end

    context 'when target config proxy is enabled' do
      it do
        @config_proxy_enabled = { env: true }
        is_expected.to eq false
      end
    end
    context 'when target config proxy target is not enabled' do
      it do
        @config_proxy_enabled = { env: false }
        is_expected.to eq true
      end
    end
    context 'when other config proxy are not enabled' do
      it do
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

   describe '#enable_auto_config_script' do
     subject do
       action = described_class.new(nil, nil)
       allow(action).to receive(:data) { data }
       action.send(:enable_auto_config_script, data)
     end

     context 'with data' do
       let(:data)   { 'DefaultConnectionSettings    REG_BINARY    460000002300000009000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000' }
       it { is_expected.to eq '460000002300000005000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'}
     end
end
