require 'spec_helper'
require 'vagrant-proxyconf/cap/linux/git_proxy_conf'

describe VagrantPlugins::ProxyConf::Cap::Linux::GitProxyConf do

  describe '.git_proxy_conf' do
    let(:subject) { described_class.git_proxy_conf(double) }
    let(:machine) { double }
    let(:communicator) { double }

    before do
      machine.stub(:communicate => communicator)
    end

    it "returns true when git is installed" do
      expect(communicator).to receive(:test).with('which git').and_return(true)
      expect(described_class.git_proxy_conf(machine)).to be_true
    end

    it "returns false when pear is not installed" do
      expect(communicator).to receive(:test).with('which git').and_return(false)
      expect(described_class.git_proxy_conf(machine)).to be_false
    end
  end

end
