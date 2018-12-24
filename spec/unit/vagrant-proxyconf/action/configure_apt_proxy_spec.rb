require 'spec_helper'
require 'vagrant-proxyconf/action/configure_apt_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureAptProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { is_expected.to eq 'apt_proxy' }
  end

  describe "#unconfigure_machine" do
    let(:app) { lambda { |env| } }
    let(:env) { Hash.new }
    let(:machine) { double('machine') }

    context 'when proxy is disabled' do
      it 'should remove file: "/etc/apt/apt.conf.d/01proxy" and return true' do
        apt_proxy = described_class.new(app, env)
        apt_proxy.instance_variable_set(:@machine, machine)

        expect(apt_proxy.config_name).to eq 'apt_proxy'

        # configure test doubles
        allow(machine).to receive_message_chain(:communicate, :sudo).with("rm -f /etc/apt/apt.conf.d/01proxy")
        allow(machine).to receive_message_chain(:guest, :capability?).with(:apt_proxy_conf).and_return(true)
        allow(machine).to receive_message_chain(:guest, :capability).with(:apt_proxy_conf).and_return("/etc/apt/apt.conf.d/01proxy")
        allow(machine).to receive_message_chain(:guest, :name).and_return('non-supported-os')

        expect(apt_proxy.send(:unconfigure_machine)).to eq true
      end
    end

    context 'when not on a supported OS' do
      it '#unconfigure_machine should return false' do
        apt_proxy = described_class.new(app, env)
        apt_proxy.instance_variable_set(:@machine, machine)

        expect(apt_proxy.config_name).to eq 'apt_proxy'

        # configure test doubles
        allow(machine).to receive_message_chain(:guest, :name).and_return('non-supported-os')
        allow(machine).to receive_message_chain(:guest, :capability?).with(:apt_proxy_conf).and_return(false)

        expect(apt_proxy.send(:unconfigure_machine)).to eq false
      end

    end


  end

end
