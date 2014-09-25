require 'spec_helper'
require 'vagrant-proxyconf/cap/linux/git_proxy_conf'
require 'vagrant-proxyconf/cap/util'

describe VagrantPlugins::ProxyConf::Cap::Linux::GitProxyConf do

  describe '.git_proxy_conf' do
    let(:machine) { double }

    it "returns the path when git is installed" do
      allow(VagrantPlugins::ProxyConf::Cap::Util).to receive(:which) { '/path/to/git' }
      expect(described_class.git_proxy_conf(machine)).to eq '/path/to/git'
    end

    it "returns false when git is not installed" do
      allow(VagrantPlugins::ProxyConf::Cap::Util).to receive(:which) { false }
      expect(described_class.git_proxy_conf(machine)).to be_falsey
    end
  end

end
