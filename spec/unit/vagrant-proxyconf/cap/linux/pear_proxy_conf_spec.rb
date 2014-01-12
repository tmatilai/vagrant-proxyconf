require 'spec_helper'
require 'vagrant-proxyconf/cap/linux/pear_proxy_conf'

describe VagrantPlugins::ProxyConf::Cap::Linux::PearProxyConf do

  describe '.pear_proxy_conf' do
    let(:machine) { double }
    let(:communicator) { double }

    before do
      machine.stub(:communicate => communicator)
    end

    it "returns true when pear is installed" do
      expect(communicator).to receive(:test).with("which pear").and_return(true)
      expect(described_class.pear_proxy_conf(machine)).to be_true
    end

    it "returns false when pear is not installed" do
      expect(communicator).to receive(:test).with("which pear").and_return(false)
      expect(described_class.pear_proxy_conf(machine)).to be_false
    end
  end

end
