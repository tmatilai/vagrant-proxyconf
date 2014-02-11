require 'spec_helper'
require 'vagrant-proxyconf/cap/linux/svn_proxy_conf'

describe VagrantPlugins::ProxyConf::Cap::Linux::SvnProxyConf do

  describe '.svn_proxy_conf' do
    let(:subject) { described_class.svn_proxy_conf(double) }
    let(:machine) { double }
    let(:communicator) { double }

    before do
      machine.stub(:communicate => communicator)
    end

    it "returns true when svn is installed" do
      expect(communicator).to receive(:test).with('which svn').and_return(true)
      expect(described_class.svn_proxy_conf(machine)).to be_true
    end

    it "returns false when pear is not installed" do
      expect(communicator).to receive(:test).with('which svn').and_return(false)
      expect(described_class.svn_proxy_conf(machine)).to be_false
    end
  end

end
