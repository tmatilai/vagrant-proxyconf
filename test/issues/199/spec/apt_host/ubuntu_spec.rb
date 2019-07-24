require 'spec_helper'

PROXY_HOST = "10.0.2.2"

context 'when proxy is enabled' do

  before(:context) do
    ENV['HTTP_PROXY']  = "http://#{PROXY_HOST}:8888"
    ENV['HTTPS_PROXY'] = "https://#{PROXY_HOST}:8888"
    ENV['NO_PROXY']    = "*.example.com"

    `vagrant provision #{ENV['TARGET_HOST']}`
    `sleep 3`
  end

  describe file('/etc/apt/apt.conf.d/01proxy') do
    let(:expected_content) do
      <<-EOS.gsub(/^\s+/, '')
        Acquire::http::Proxy "http://10.0.2.2:8888";
        Acquire::https::Proxy "https://10.0.2.2:8888";
      EOS
    end

    its(:content) do
       should eq(expected_content)
    end
  end

end

context 'when VAGRANT_APT_VERIFY_PEER="false"' do

  before(:context) do
    ENV['HTTP_PROXY']  = "http://#{PROXY_HOST}:8888"
    ENV['HTTPS_PROXY']             = "https://#{PROXY_HOST}:8888"
    ENV['NO_PROXY']                = "*.example.com"
    ENV['VAGRANT_APT_VERIFY_PEER'] = "false"

    `vagrant provision #{ENV['TARGET_HOST']}`
    `sleep 3`
  end

  describe file('/etc/apt/apt.conf.d/01proxy') do
    let(:expected_content) do
      <<-EOS.gsub(/^\s+/, '')
        Acquire::http::Proxy "http://10.0.2.2:8888";
        Acquire::https::Proxy "https://10.0.2.2:8888";
        Acquire::https::Verify-Peer "false";
      EOS
    end

    its(:content) do
       should eq(expected_content)
    end
  end

end

context 'when VAGRANT_APT_VERIFY_PEER="true" and VAGRANT_APT_VERIFY_HOST="false"' do

  before(:context) do
    ENV['HTTP_PROXY']  = "http://#{PROXY_HOST}:8888"
    ENV['HTTPS_PROXY']             = "https://#{PROXY_HOST}:8888"
    ENV['NO_PROXY']                = "*.example.com"
    ENV['VAGRANT_APT_VERIFY_PEER'] = "true"
    ENV['VAGRANT_APT_VERIFY_HOST'] = "false"

    `vagrant provision #{ENV['TARGET_HOST']}`
    `sleep 3`
  end

  describe file('/etc/apt/apt.conf.d/01proxy') do
    let(:expected_content) do
      <<-EOS.gsub(/^\s+/, '')
        Acquire::http::Proxy "http://10.0.2.2:8888";
        Acquire::https::Proxy "https://10.0.2.2:8888";
        Acquire::https::Verify-Peer "true";
        Acquire::https::Verify-Host "false";
      EOS
    end

    its(:content) do
       should eq(expected_content)
    end
  end

end

context 'when VAGRANT_APT_VERIFY_PEER="" and VAGRANT_APT_VERIFY_HOST=""' do

  before(:context) do
    ENV['HTTP_PROXY']  = "http://#{PROXY_HOST}:8888"
    ENV['HTTPS_PROXY']             = "https://#{PROXY_HOST}:8888"
    ENV['NO_PROXY']                = "*.example.com"
    ENV['VAGRANT_APT_VERIFY_PEER'] = ""
    ENV['VAGRANT_APT_VERIFY_HOST'] = ""

    `vagrant provision #{ENV['TARGET_HOST']}`
    `sleep 3`
  end

  describe file('/etc/apt/apt.conf.d/01proxy') do
    let(:expected_content) do
      <<-EOS.gsub(/^\s+/, '')
        Acquire::http::Proxy "http://10.0.2.2:8888";
        Acquire::https::Proxy "https://10.0.2.2:8888";
      EOS
    end

    its(:content) do
       should eq(expected_content)
    end
  end

end

context 'when VAGRANT_APT_VERIFY_PEER="true" and VAGRANT_APT_VERIFY_HOST="true" but proxy is disabled' do

  before(:context) do
    ENV['HTTP_PROXY']  = "http://#{PROXY_HOST}:8888"
    ENV['HTTPS_PROXY']             = "https://#{PROXY_HOST}:8888"
    ENV['NO_PROXY']                = "*.example.com"
    ENV['VAGRANT_APT_VERIFY_PEER'] = "true"
    ENV['VAGRANT_APT_VERIFY_HOST'] = "true"
    ENV['VAGRANT_APT_PROXY_ENABLED'] = "false"

    `vagrant provision #{ENV['TARGET_HOST']}`
    `sleep 3`
  end

  describe file('/etc/apt/apt.conf.d/01proxy') do
    it { should_not exist }
  end

end
