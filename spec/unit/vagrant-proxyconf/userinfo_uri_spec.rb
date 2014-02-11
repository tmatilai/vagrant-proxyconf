require 'spec_helper'
require 'vagrant-proxyconf/userinfo_uri'

describe VagrantPlugins::ProxyConf::UserinfoURI do

  subject { described_class.new(uri) }

  context "with nil" do
    let(:uri)  { nil }
    its(:to_s) { should be_nil }
    its(:uri)  { should be_nil }
    its(:host) { should be_nil }
    its(:port) { should be_nil }
    its(:user) { should be_nil }
    its(:pass) { should be_nil }
  end

  context "with false" do
    let(:uri)  { false }
    its(:to_s) { should be_nil }
    its(:uri)  { should be_nil }
    its(:host) { should be_nil }
    its(:port) { should be_nil }
    its(:user) { should be_nil }
    its(:pass) { should be_nil }
  end

  context "with empty" do
    let(:uri)  { '' }
    its(:to_s) { should eq '' }
    its(:uri)  { should eq '' }
    its(:host) { should be_nil }
    its(:port) { should be_nil }
    its(:user) { should be_nil }
    its(:pass) { should be_nil }
  end

  context "without userinfo" do
    let(:uri)  { 'http://proxy.example.com:8123' }
    its(:to_s) { should eq 'http://proxy.example.com:8123' }
    its(:uri)  { should eq 'http://proxy.example.com:8123' }
    its(:host) { should eq 'proxy.example.com' }
    its(:port) { should eq 8123 }
    its(:user) { should be_nil }
    its(:pass) { should be_nil }
  end

  context "with username" do
    let(:uri)  { 'http://foo@proxy.example.com:8123/' }
    its(:to_s) { should eq 'http://proxy.example.com:8123' }
    its(:uri)  { should eq 'http://proxy.example.com:8123' }
    its(:host) { should eq 'proxy.example.com' }
    its(:port) { should eq 8123 }
    its(:user) { should eq 'foo' }
    its(:pass) { should be_nil }
  end

  context "with password" do
    let(:uri)  { 'http://:bar@proxy.example.com:8123' }
    its(:to_s) { should eq 'http://proxy.example.com:8123' }
    its(:uri)  { should eq 'http://proxy.example.com:8123' }
    its(:host) { should eq 'proxy.example.com' }
    its(:port) { should eq 8123 }
    its(:user) { should eq '' }
    its(:pass) { should eq 'bar' }
  end

  context "with userinfo" do
    let(:uri)  { 'http://foo:bar@proxy.example.com:8123/' }
    its(:to_s) { should eq 'http://proxy.example.com:8123' }
    its(:uri)  { should eq 'http://proxy.example.com:8123' }
    its(:host) { should eq 'proxy.example.com' }
    its(:port) { should eq 8123 }
    its(:user) { should eq 'foo' }
    its(:pass) { should eq 'bar' }
  end

  context "without port" do
    let(:uri)  { 'http://foo:bar@proxy.example.com' }
    its(:to_s) { should eq 'http://proxy.example.com:80' }
    its(:uri)  { should eq 'http://proxy.example.com:80' }
    its(:host) { should eq 'proxy.example.com' }
    its(:port) { should eq 80 }
    its(:user) { should eq 'foo' }
    its(:pass) { should eq 'bar' }
  end

  context "with default port" do
    let(:uri)  { 'http://proxy.example.com:80/' }
    its(:to_s) { should eq 'http://proxy.example.com:80' }
    its(:uri)  { should eq 'http://proxy.example.com:80' }
    its(:host) { should eq 'proxy.example.com' }
    its(:port) { should eq 80 }
    its(:user) { should be_nil }
    its(:pass) { should be_nil }
  end

end
