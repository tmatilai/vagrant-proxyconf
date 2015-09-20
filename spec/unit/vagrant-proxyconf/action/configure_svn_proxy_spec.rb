require 'spec_helper'
require 'vagrant-proxyconf/action/configure_svn_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureSvnProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { is_expected.to eq 'svn_proxy' }
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
