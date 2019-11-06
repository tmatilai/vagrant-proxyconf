require 'spec_helper'

PROXY_HOST = "10.0.2.2"

describe service('docker') do
  it { should be_running }
  it { should be_enabled  }
end

describe file('/etc/docker/config.json') do
  it { should be_file }
  it { should exist }
  it { should be_mode 644 }
  it { should be_owned_by "root" }
  it { should be_grouped_into "docker" }
end

context 'when proxy is enabled' do

  before(:context) do
    ENV['HTTP_PROXY']  = "http://#{PROXY_HOST}:8888"
    ENV['HTTPS_PROXY'] = "http://#{PROXY_HOST}:8888"
    ENV['NO_PROXY']    = "*.example.com"

    `vagrant provision #{ENV['TARGET_HOST']}`
    `sleep 3`
  end

  describe file('/etc/docker/config.json') do
    let(:expected_content) do
      {
        "proxies" => {
          "default" => {
            "httpProxy"  => "http://10.0.2.2:8888",
            "httpsProxy" => "http://10.0.2.2:8888",
             "noProxy"   => "*.example.com",
          }
        }
      }
    end

    its(:content_as_json) do
       should include(expected_content)
    end
  end

end

context 'when HTTP_PROXY=""' do

  before(:context) do
    ENV['HTTP_PROXY']  = ""
    ENV['HTTPS_PROXY'] = "https://#{PROXY_HOST}:8888"
    ENV['NO_PROXY']    = "*.example.com"

    `vagrant provision #{ENV['TARGET_HOST']}`
    `sleep 3`
  end

  describe file('/etc/docker/config.json') do
    let(:expected_content) do
      {
        "proxies" => {
          "default" => {
            "httpsProxy" => "https://#{PROXY_HOST}:8888",
             "noProxy"   => "*.example.com",
          }
        }
      }
    end

    its(:content_as_json) do
       should include(expected_content)
    end
  end

end

context 'when HTTPS_PROXY=""' do

  before(:context) do
    ENV['HTTP_PROXY']  = "http://#{PROXY_HOST}:8888"
    ENV['HTTPS_PROXY'] = ""
    ENV['NO_PROXY']    = "*.example.com"

    `vagrant provision #{ENV['TARGET_HOST']}`
  end

  describe file('/etc/docker/config.json') do
    let(:expected_content) do
      {
        "proxies" => {
          "default" => {
            "httpProxy"  => "http://#{PROXY_HOST}:8888",
             "noProxy"   => "*.example.com",
          }
        }
      }
    end

    its(:content_as_json) do
       should include(expected_content)
    end
  end

end

context 'when HTTPS_PROXY="" and HTTP_PROXY=""' do

  before(:context) do
    ENV['HTTP_PROXY']  = ""
    ENV['HTTPS_PROXY'] = ""
    ENV['NO_PROXY']    = "*.example.com"

    `vagrant provision #{ENV['TARGET_HOST']}`
    `sleep 3`
  end

  describe file('/etc/docker/config.json') do
    let(:expected_content) do
      {
        "proxies" => {
          "default" => {
             "noProxy"   => "*.example.com",
          }
        }
      }
    end

    its(:content_as_json) do
       should include(expected_content)
    end
  end

end

context 'when NO_PROXY=""' do

  before(:context) do
    ENV['HTTP_PROXY']  = "http://#{PROXY_HOST}:8888"
    ENV['HTTPS_PROXY'] = "https://#{PROXY_HOST}:8888"
    ENV['NO_PROXY']    = ""

    `vagrant provision #{ENV['TARGET_HOST']}`
    `sleep 3`
  end

  describe file('/etc/docker/config.json') do
    let(:expected_content) do
      {
        "proxies" => {
          "default" => {
             "httpProxy" => "http://#{PROXY_HOST}:8888",
             "httpsProxy" => "https://#{PROXY_HOST}:8888",
          }
        }
      }
    end

    its(:content_as_json) do
       should include(expected_content)
    end
  end

end
