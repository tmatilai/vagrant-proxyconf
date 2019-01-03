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

  describe "#skip?" do
    let(:machine) { double('machine') }

    let(:config) { OpenStruct.new }

    subject do
      apt_proxy = described_class.new(nil, nil)
      apt_proxy.instance_variable_set(:@machine, machine)

      allow(machine).to receive_message_chain(:config, :proxy) { config }

      apt_proxy.send(:skip?)
    end

    context "when config.proxy.enabled[:apt] = false" do
      before(:each) do
        config.enabled = {:apt => false}
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq true }
    end

    context "when config.proxy.enabled[:apt] = true" do
      before(:each) do
        config.enabled = {:apt => true}
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq false }
    end

    context "when config.proxy.enabled[:apt] = {:enabled => false, :skip => false}" do
      before(:each) do
        config.enabled = {
          :apt => {
            :enabled => false,
            :skip    => false,
          }
        }
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq false }
    end

    context "when config.proxy.enabled[:apt] = {:enabled => true, :skip => false}" do
      before(:each) do
        config.enabled = {
          :apt => {
            :enabled => true,
            :skip    => false,
          }
        }
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq false }
    end

    context "when config.proxy.enabled[:apt] = {:enabled => true, :skip => true}" do
      before(:each) do
        config.enabled = {
          :apt => {
            :enabled => true,
            :skip    => true,
          }
        }
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq true }
    end

    context "when config.proxy.enabled[:apt] = {:enabled => false, :skip => true}" do
      before(:each) do
        config.enabled = {
          :apt => {
            :enabled => false,
            :skip    => true,
          }
        }
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq true }
    end

    context "when config.proxy.enabled = false" do
      before(:each) do
        config.enabled = false
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq true }
    end

    context "when config.proxy.enabled = true " do
      before(:each) do
        config.enabled = true
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq false }
    end
  end

end
