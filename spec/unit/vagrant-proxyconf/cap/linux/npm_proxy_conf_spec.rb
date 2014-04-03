require 'spec_helper'
require 'vagrant-proxyconf/cap/linux/npm_proxy_conf'

describe VagrantPlugins::ProxyConf::Cap::Linux::NpmProxyConf do

  describe '.npm_proxy_conf' do
    let(:machine) { double }
    let(:communicator) { double }

    before do
      machine.stub(:communicate => communicator)
    end

    it "returns true when npm is installed" do
      expect(communicator).
        to receive(:test).with('which npm', sudo: true).and_return(true)
      expect(described_class.npm_proxy_conf(machine)).to be_true
    end

    it "returns false when npm is not installed" do
      expect(communicator).
        to receive(:test).with('which npm', sudo: true).and_return(false)
      expect(described_class.npm_proxy_conf(machine)).to be_false
    end
  end

end
