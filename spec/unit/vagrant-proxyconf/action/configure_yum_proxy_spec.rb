require 'spec_helper'
require 'vagrant-proxyconf/action/configure_yum_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureYumProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { is_expected.to eq 'yum_proxy' }
  end

  describe '#proxy_params' do
    subject do
      action = described_class.new(nil, nil)
      allow(action).to receive(:config) { config }
      action.send(:proxy_params)
    end
    let(:config) { OpenStruct.new(http: http) }

    context "with `false`" do
      let(:http) { false }
      it { is_expected.to eq %q{-v proxy='' -v user='' -v pass=''} }
    end

    context "without userinfo" do
      let(:http) { 'http://proxy:1234/' }
      it { is_expected.to eq %q{-v proxy=http://proxy:1234 -v user='' -v pass=''} }
    end

    context "with userinfo" do
      let(:http) { 'http://foo:bar@myproxy:9876' }
      it { is_expected.to eq %q{-v proxy=http://myproxy:9876 -v user=foo -v pass=bar} }
    end

    context "with special characters" do
      let(:http) { %q{http://x*y:a(%28b@proxy.com:8080} }
      it { is_expected.to eq %q{-v proxy=http://proxy.com:8080 -v user=x\\*y -v pass=a\\(\\(b} }
    end
  end
end
