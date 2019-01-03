require 'spec_helper'
require 'vagrant-proxyconf/cap/linux/docker_proxy_conf'
require 'vagrant-proxyconf/cap/util'

describe VagrantPlugins::ProxyConf::Cap::Linux::DockerProxyConf do

  describe '.docker_proxy_conf' do
    let(:machine) { double }
    let(:communicator) { double }

    before do
      allow(machine).to receive(:communicate) { communicator }
    end

    it "returns the path when docker is installed on Redhat" do
      allow(VagrantPlugins::ProxyConf::Cap::Util).to receive(:which) do |_m, c|
        (c == 'docker') ? '/path/to/docker' : false
      end
      allow(communicator).to receive(:test) do |c|
        c == '[ -f /etc/redhat-release ]'
      end

      expect(described_class.docker_proxy_conf(machine)).to eq '/etc/sysconfig/docker'
    end

    it "returns the path when docker is installed on Debian or Ubuntu" do
      allow(VagrantPlugins::ProxyConf::Cap::Util).to receive(:which) do |_m, c|
        (c == 'docker') ? '/path/to/docker' : false
      end
      allow(communicator).to receive(:test) { false }

      expect(described_class.docker_proxy_conf(machine)).to eq '/etc/default/docker'
    end

    it "returns the path when docker.io is installed on Ubuntu 14.04 or higher" do
      allow(VagrantPlugins::ProxyConf::Cap::Util).to receive(:which) do |_m, c|
        (c == 'docker.io') ? '/path/to/docker.io': false
      end
      allow(communicator).to receive(:test) { false }

      expect(described_class.docker_proxy_conf(machine)).to eq '/etc/default/docker.io'
    end

    it "returns the path when docker is installed on boot2docker" do
      allow(VagrantPlugins::ProxyConf::Cap::Util).to receive(:which) do |_m, c|
        (c == 'docker') ? '/path/to/docker' : false
      end
      allow(communicator).to receive(:test) do |c|
        c == 'ls /var/lib/boot2docker'
      end

      expect(described_class.docker_proxy_conf(machine)).to eq '/etc/default/docker'
    end

    it "returns false when docker is not installed" do
      allow(VagrantPlugins::ProxyConf::Cap::Util).to receive(:which) { false }
      expect(described_class.docker_proxy_conf(machine)).to be_falsey
    end
  end
end
