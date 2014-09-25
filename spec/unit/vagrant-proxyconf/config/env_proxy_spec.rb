require 'spec_helper'
require 'vagrant-proxyconf/config/env_proxy'

def config_with(options)
  instance.tap do |c|
    options.each_pair { |k, v| c.public_send("#{k}=".to_sym, v) }
    c.finalize!
  end
end

RSpec::Matchers.define :match_lines do |expected|
  match do |actual|
    expect(actual.lines.to_a).to match_array(expected)
  end
end

describe VagrantPlugins::ProxyConf::Config::EnvProxy do
  let(:instance) { described_class.new }

  before :each do
    # Ensure tests are not affected by environment variables
    %w[HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY].each do |var|
      ENV.delete("VAGRANT_ENV_#{var}")
    end
  end

  context "defaults" do
    subject        { config_with({}) }
    its(:enabled?) { should be_falsey }
    its(:to_s)     { should eq "" }
  end

  context "with http config" do
    let(:proxy)    { 'http://proxy.example.com:8888' }
    subject        { config_with({ http: proxy }) }
    its(:enabled?) { should be_truthy }
    its(:to_s)     { should match_lines [
      %Q{export HTTP_PROXY=#{proxy}\n},
      %Q{export http_proxy=#{proxy}\n},
    ] }
  end

  context "with http and no_proxy config" do
    let(:proxy)    { 'http://proxy.example.com:8888' }
    let(:no_proxy) { 'localhost, 127.0.0.1' }
    subject        { config_with({ http: proxy, no_proxy: no_proxy }) }
    its(:enabled?) { should be_truthy }
    its(:to_s)     { should match_lines [
      %Q{export HTTP_PROXY=#{proxy}\n},
      %Q{export http_proxy=#{proxy}\n},
      %Q{export NO_PROXY="#{no_proxy}"\n},
      %Q{export no_proxy="#{no_proxy}"\n},
    ] }
  end

  context "with VAGRANT_ENV_HTTP_PROXY env var" do
    let(:proxy)    { 'http://proxy.example.com:8888' }
    before(:each)  { ENV['VAGRANT_ENV_HTTP_PROXY'] = proxy }
    subject        { config_with({ http: 'http://default:3128' }) }
    its(:enabled?) { should be_truthy }
    its(:to_s)     { should match_lines [
      %Q{export HTTP_PROXY=#{proxy}\n},
      %Q{export http_proxy=#{proxy}\n},
    ] }
  end
end
