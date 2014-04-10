require 'spec_helper'
require 'vagrant-proxyconf/cap/linux/svn_proxy_conf'
require 'vagrant-proxyconf/cap/util'

describe VagrantPlugins::ProxyConf::Cap::Linux::SvnProxyConf do

  describe '.svn_proxy_conf' do
    let(:machine) { double }

    it "returns true when svn is installed" do
      VagrantPlugins::ProxyConf::Cap::Util.stub(which: '/path/to/svn')
      expect(described_class.svn_proxy_conf(machine)).to eq '/path/to/svn'
    end

    it "returns false when pear is not installed" do
      VagrantPlugins::ProxyConf::Cap::Util.stub(which: false)
      expect(described_class.svn_proxy_conf(machine)).to be_false
    end
  end

end
