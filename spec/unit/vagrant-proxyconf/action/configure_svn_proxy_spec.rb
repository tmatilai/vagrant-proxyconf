require 'spec_helper'
require 'vagrant-proxyconf/action/configure_svn_proxy'

def mock_write_config(machine)
  allow(machine).to receive_message_chain(:communicate, :sudo).with("rm -f /tmp/vagrant-proxyconf", error_check: false)
  allow(machine).to receive_message_chain(:communicate, :upload)
  allow(machine).to receive_message_chain(:communicate, :sudo).with("chmod 0644 /tmp/vagrant-proxyconf")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("chown root:root /tmp/vagrant-proxyconf")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("mkdir -p /etc/subversion")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("mv -f /tmp/vagrant-proxyconf /etc/subversion/servers")
end

describe VagrantPlugins::ProxyConf::Action::ConfigureSvnProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { is_expected.to eq 'svn_proxy' }
  end

  describe "#configure_machine" do
    let(:config) { OpenStruct.new }
    let(:machine) { double('machine') }

    subject do
      svn_proxy = described_class.new(nil, nil)
      svn_proxy.instance_variable_set(:@machine, machine)

      allow(svn_proxy).to receive(:config) { config }
      allow(machine).to receive_message_chain(:guest, :capability?).with(:svn_proxy_conf).and_return(@supported)
      allow(machine).to receive_message_chain(:guest, :capability).with(:svn_proxy_conf).and_return(@supported)

      mock_write_config(machine)

      svn_proxy.send(:configure_machine)
    end

    it 'returns nil, when not supported' do
      @supported = false

      config.http = 'http://some-svn-proxy:8080'
      config.no_proxy = 'localhost'

      is_expected.to eq nil
    end

    it 'returns true, when supported' do
      @supported = true

      config.http = 'http://some-svn-proxy:8080'
      config.no_proxy = 'localhost'

      is_expected.to eq true
    end

  end

  describe "#unconfigure_machine" do
    let(:config) { OpenStruct.new }
    let(:machine) { double('machine') }

    subject do
      svn_proxy = described_class.new(nil, nil)
      svn_proxy.instance_variable_set(:@machine, machine)

      allow(svn_proxy).to receive(:config) { config }
      allow(machine).to receive_message_chain(:guest, :capability?).with(:svn_proxy_conf).and_return(@supported)
      allow(machine).to receive_message_chain(:guest, :capability).with(:svn_proxy_conf).and_return(@supported)

      allow(machine).to receive_message_chain(:communicate, :sudo).with("sed -i.bak -e '/^http-proxy-/d' /etc/subversion/servers")

      svn_proxy.send(:unconfigure_machine)
    end

    it 'returns nil, when not supported' do
      @supported = false

      config.http = 'http://some-svn-proxy:8080'
      config.no_proxy = 'localhost'

      is_expected.to eq nil
    end

    it 'returns true, when supported' do
      @supported = true

      config.http = 'http://some-svn-proxy:8080'
      config.no_proxy = 'localhost'

      is_expected.to eq true
    end
  end

  describe '#svn_config' do
    subject do
      action = described_class.new(nil, nil)
      allow(action).to receive(:config) { config }
      action.send(:svn_config)
    end
    let(:config) { OpenStruct.new(http: http) }
    let(:uri_encoded) { false }

    context "with `false`" do
      let(:http) { false }
      it do
        is_expected.to eq <<-CONFIG
[global]
http-proxy-host=
http-proxy-port=
http-proxy-username=
http-proxy-password=
http-proxy-exceptions=
        CONFIG
      end
    end

    context "without userinfo" do
      let(:http) { 'http://proxy:1234/' }
      it do
        is_expected.to eq <<-CONFIG
[global]
http-proxy-host=proxy
http-proxy-port=1234
http-proxy-username=
http-proxy-password=
http-proxy-exceptions=
        CONFIG
      end
    end

    context "with userinfo" do
      let(:http) { 'http://foo:bar@myproxy:9876' }
      it do
        is_expected.to eq <<-CONFIG
[global]
http-proxy-host=myproxy
http-proxy-port=9876
http-proxy-username=foo
http-proxy-password=bar
http-proxy-exceptions=
        CONFIG
      end
    end

    context "with special characters" do
      let(:http) { %q{http://x*y:a(b@proxy.com:8080} }
      it do
        is_expected.to eq <<-CONFIG
[global]
http-proxy-host=proxy.com
http-proxy-port=8080
http-proxy-username=x*y
http-proxy-password=a(b
http-proxy-exceptions=
        CONFIG
      end
    end

    context "with URI encoded special characters" do
      let(:http) { %q{http://foo%25:abc%23123@proxy.com:8080} }
      it do
        is_expected.to eq <<-CONFIG
[global]
http-proxy-host=proxy.com
http-proxy-port=8080
http-proxy-username=foo%
http-proxy-password=abc#123
http-proxy-exceptions=
        CONFIG
      end
    end
  end
end
