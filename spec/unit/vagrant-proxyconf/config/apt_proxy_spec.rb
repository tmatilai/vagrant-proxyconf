require 'spec_helper'
require 'unit/support/shared/apt_proxy_config'
require 'vagrant-proxyconf/config/apt_proxy'

describe VagrantPlugins::ProxyConf::Config::AptProxy do
  let(:instance) { described_class.new }

  before :each do
    # Ensure tests are not affected by environment variables
    %w[HTTP HTTPS FTP].map { |proto| ENV.delete("VAGRANT_APT_#{proto}_PROXY") }
  end

  context "defaults" do
    subject        { config_with({}) }
    its(:enabled?) { should be_falsey }
    its(:to_s)     { should eq "" }
  end

  include_examples "apt proxy config", "http"
  include_examples "apt proxy config", "https"
  include_examples "apt proxy config", "ftp"
  include_examples "apt proxy config", "verify_host"
  include_examples "apt proxy config", "verify_peer"

  context "with both http and https proxies" do
    subject        { config_with(http: "10.2.3.4", https: "ssl-proxy:8443") }
    its(:enabled?) { should be_truthy }
    its(:to_s)     { should match conf_line_pattern("http", "10.2.3.4") }
    its(:to_s)     { should match conf_line_pattern("https", "ssl-proxy", 8443) }
  end

  context "with env var" do
    include_examples "apt proxy env var", "VAGRANT_APT_HTTP_PROXY", "http"
    include_examples "apt proxy env var", "VAGRANT_APT_HTTPS_PROXY", "https"
    include_examples "apt proxy env var", "VAGRANT_APT_FTP_PROXY", "ftp"
    include_examples "apt proxy env var", "VAGRANT_APT_VERIFY_HOST", "verify_host"
    include_examples "apt proxy env var", "VAGRANT_APT_VERIFY_PEER", "verify_peer"
  end

end
