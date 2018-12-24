require 'pry'
require 'spec_helper'
require 'vagrant-proxyconf/action/configure_npm_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureNpmProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { is_expected.to eq 'npm_proxy' }
  end

  describe '#set_or_delete_proxy' do
    let(:app) { OpenStruct.new }
    let(:env) { OpenStruct.new }
    let(:machine) { double('machine') }

    context "when not supported" do
      subject do
        npm_proxy = described_class.new(app, env)
        npm_proxy.instance_variable_set(:@machine, machine)

        allow(machine).to receive_message_chain(:guest, :capability?).with(:npm_proxy_conf).and_return(false)
        allow(machine).to receive_message_chain(:guest, :capability).with(:npm_proxy_conf).and_return(nil)

        npm_proxy.send(:set_or_delete_proxy, @key, @value)
      end

      it 'return nil' do
        @key = "proxy"
        @value = "http://proxy-server-01.example.com:8888"
        is_expected.to eq nil
      end
    end

    context 'when supported' do
      context 'and has value argument' do
        subject do
          npm_proxy = described_class.new(app, env)
          npm_proxy.instance_variable_set(:@machine, machine)

          allow(machine).to receive_message_chain(:guest, :capability?).with(:npm_proxy_conf).and_return(true)
          allow(machine).to receive_message_chain(:guest, :capability).with(:npm_proxy_conf).and_return("/usr/bin/npm")

          allow(machine).to receive_message_chain(:communicate, :sudo).with("/usr/bin/npm config --global set #{@key} #{@value}")

          npm_proxy.send(:set_or_delete_proxy, @key, @value)
        end

        it 'should set npm config item' do
          @key = "proxy"
          @value = "http://proxyserver:8080"
          is_expected.to eq true
        end
      end

      context 'and does not have value argument' do
        subject do
          npm_proxy = described_class.new(app, env)
          npm_proxy.instance_variable_set(:@machine, machine)

          allow(machine).to receive_message_chain(:guest, :capability?).with(:npm_proxy_conf).and_return(true)
          allow(machine).to receive_message_chain(:guest, :capability).with(:npm_proxy_conf).and_return("/usr/bin/npm")

          allow(machine).to receive_message_chain(:communicate, :sudo).with("/usr/bin/npm config --global set #{@key} foo")
          allow(machine).to receive_message_chain(:communicate, :sudo).with("/usr/bin/npm config --global delete #{@key}")

          npm_proxy.send(:set_or_delete_proxy, @key, @value)
        end

        it 'should delete npm config item' do
          @key = "proxy"
          @value = nil
          is_expected.to eq true
        end
      end
    end
  end
end
