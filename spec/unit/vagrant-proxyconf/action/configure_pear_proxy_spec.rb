require 'pry'
require 'spec_helper'
require 'vagrant-proxyconf/action/configure_pear_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigurePearProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { is_expected.to eq 'pear_proxy' }
  end

  describe "#configure_machine" do
    let(:app) { OpenStruct.new }
    let(:env) { OpenStruct.new }
    let(:machine) { double('machine') }

    context "when not supported" do
      subject do
        pear_proxy = described_class.new(app, env)
        pear_proxy.instance_variable_set(:@machine, machine)

        allow(machine).to receive_message_chain(:guest, :capability?).with(:pear_proxy_conf).and_return(false)
        allow(machine).to receive_message_chain(:guest, :capability).with(:pear_proxy_conf).and_return(nil)

        pear_proxy.send(:configure_machine)
      end

      it 'returns nil' do
        is_expected.to eq nil
      end
    end

    context "when supported" do
      subject do
        pear_proxy = described_class.new(app, env)
        pear_proxy.instance_variable_set(:@machine, machine)

        allow(machine).to receive_message_chain(:guest, :capability?).with(:pear_proxy_conf).and_return(true)
        allow(machine).to receive_message_chain(:guest, :capability).with(:pear_proxy_conf).and_return('/usr/bin/pear')

        allow(machine).to receive_message_chain(:config, :proxy).and_return(@config)
        allow(machine).to receive_message_chain(:config, :public_send).with(:pear_proxy).and_return(@config)

        allow(machine).to receive_message_chain(:communicate, :sudo).with("/usr/bin/pear config-set http_proxy #{@http_proxy} system")

        pear_proxy.send(:configure_machine)
      end

      it 'and not disabled, sets http proxy to http://proxy:8080' do
        @config = create_config_proxy(
           :enabled  => true,
           :http     => 'http://proxy:8080',
           :https    => 'https://proxy:8080',
           :no_proxy => 'localhost',
        )
        @http_proxy = "http://proxy:8080"

        is_expected.to eq true
      end

      it 'and disabled, disables the proxy' do
        @config = create_config_proxy(
           :enabled  => false,
           :http     => 'http://proxy:8080',
           :https    => 'https://proxy:8080',
           :no_proxy => 'localhost',
        )
        @http_proxy = "''"

        is_expected.to eq true
      end
    end
  end

  describe "#unconfigure_machine" do
    let(:app) { OpenStruct.new }
    let(:env) { OpenStruct.new }
    let(:machine) { double('machine') }

    context "when not supported" do
      subject do
        pear_proxy = described_class.new(app, env)
        pear_proxy.instance_variable_set(:@machine, machine)

        allow(machine).to receive_message_chain(:guest, :capability?).with(:pear_proxy_conf).and_return(false)
        allow(machine).to receive_message_chain(:guest, :capability).with(:pear_proxy_conf).and_return(nil)

        pear_proxy.send(:unconfigure_machine)
      end

      it 'returns nil' do
        is_expected.to eq nil
      end
    end

    context "when supported" do
      subject do
        pear_proxy = described_class.new(app, env)
        pear_proxy.instance_variable_set(:@machine, machine)

        allow(machine).to receive_message_chain(:guest, :capability?).with(:pear_proxy_conf).and_return(true)
        allow(machine).to receive_message_chain(:guest, :capability).with(:pear_proxy_conf).and_return('/usr/bin/pear')

        allow(machine).to receive_message_chain(:config, :proxy).and_return(@config)
        allow(machine).to receive_message_chain(:config, :public_send).with(:pear_proxy).and_return(@config)

        allow(machine).to receive_message_chain(:communicate, :sudo).with("/usr/bin/pear config-set http_proxy #{@http_proxy} system")

        pear_proxy.send(:unconfigure_machine)
      end

      it 'disables http proxy' do
        @config = create_config_proxy(
           :enabled  => false,
           :http     => nil,
           :https    => nil,
           :no_proxy => nil,
        )
        @http_proxy = "''"

        is_expected.to eq true
      end
    end
  end


end
