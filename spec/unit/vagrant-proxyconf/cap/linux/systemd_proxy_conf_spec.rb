require 'spec_helper'
require 'vagrant-proxyconf/cap/linux/systemd_proxy_conf'
require 'vagrant-proxyconf/cap/util'

describe VagrantPlugins::ProxyConf::Cap::Linux::SystemdProxyConf do

  describe '.systemd_proxy_conf' do
    let(:machine) { double }
    let(:communicator) { double }

    before do
      allow(machine).to receive(:communicate) { communicator }
    end

    it "returns the path when systemd is installed on Redhat/Ubuntu/Debian" do
      allow(VagrantPlugins::ProxyConf::Cap::Util).to receive(:which) do |_m, c|
        (c == 'systemctl') ? '/path/to/systemctl' : false
      end

      expect(described_class.systemd_proxy_conf(machine)).to eq '/etc/systemd/system.conf'
    end

    it "returns false when systemd is not installed" do
      allow(VagrantPlugins::ProxyConf::Cap::Util).to receive(:which) { false }
      expect(described_class.systemd_proxy_conf(machine)).to be_falsey
    end
  end
end
