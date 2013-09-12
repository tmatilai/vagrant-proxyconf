require 'spec_helper'
require 'vagrant-proxyconf/config/proxy'

describe VagrantPlugins::ProxyConf::Config::Proxy do
  before :each do
    # Ensure tests are not affected by environment variables
    %w[HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY].each do |var|
      ENV.delete("VAGRANT_#{var}")
    end
  end

  subject do
    described_class.new.tap do |config|
      config.http  = http_proxy
      config.https = https_proxy
    end
  end
  let(:http_proxy)  { nil }
  let(:https_proxy) { nil }

  context "defaults" do
    its(:http_user)  { should be_nil }
    its(:http_pass)  { should be_nil }
    its(:https_user) { should be_nil }
    its(:https_pass) { should be_nil }
  end

  context "without userinfo" do
    let(:http_proxy)  { 'http://proxy.example.com:8123/' }
    let(:https_proxy) { '' }

    its(:http_user)  { should be_nil }
    its(:http_pass)  { should be_nil }
    its(:https_user) { should be_nil }
    its(:https_pass) { should be_nil }
  end

  context "with username" do
    let(:http_proxy)  { 'http://foo@proxy.example.com:8123/' }
    let(:https_proxy) { 'http://bar@localhost' }

    its(:http_user)  { should eq 'foo' }
    its(:http_pass)  { should be_nil }
    its(:https_user) { should eq 'bar' }
    its(:https_pass) { should be_nil }
  end

  context "with userinfo" do
    let(:http_proxy)  { 'http://foo:bar@proxy.example.com:8123/' }
    let(:https_proxy) { 'http://:baz@localhost' }

    its(:http_user)  { should eq 'foo' }
    its(:http_pass)  { should eq 'bar' }
    its(:https_user) { should eq '' }
    its(:https_pass) { should eq 'baz' }
  end

  context "with false" do
    let(:http_proxy)  { false }
    let(:https_proxy) { false }

    its(:http_user)  { should be_nil }
    its(:http_pass)  { should be_nil }
    its(:https_user) { should be_nil }
    its(:https_pass) { should be_nil }
  end
end
