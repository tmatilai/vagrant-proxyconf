require 'spec_helper'
require 'vagrant-proxyconf/cap/linux/pear_proxy_conf'
require 'vagrant-proxyconf/cap/util'

describe VagrantPlugins::ProxyConf::Cap::Linux::PearProxyConf do

  describe '.pear_proxy_conf' do
    let(:machine) { double }

    it "returns the path when pear is installed" do
      VagrantPlugins::ProxyConf::Cap::Util.stub(which: '/path/to/pear')
      expect(described_class.pear_proxy_conf(machine)).to eq '/path/to/pear'
    end

    it "returns false when pear is not installed" do
      VagrantPlugins::ProxyConf::Cap::Util.stub(which: false)
      expect(described_class.pear_proxy_conf(machine)).to be_false
    end
  end

end
