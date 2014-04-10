require 'spec_helper'
require 'vagrant-proxyconf/cap/linux/npm_proxy_conf'
require 'vagrant-proxyconf/cap/util'

describe VagrantPlugins::ProxyConf::Cap::Linux::NpmProxyConf do

  describe '.npm_proxy_conf' do
    let(:machine) { double }

    it "returns the path when npm is installed" do
      VagrantPlugins::ProxyConf::Cap::Util.stub(which: '/path/to/npm')
      expect(described_class.npm_proxy_conf(machine)).to eq '/path/to/npm'
    end

    it "returns false when npm is not installed" do
      VagrantPlugins::ProxyConf::Cap::Util.stub(which: false)
      expect(described_class.npm_proxy_conf(machine)).to be_false
    end
  end

end
