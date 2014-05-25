require 'spec_helper'
require 'vagrant-proxyconf/cap/linux/docker_proxy_conf'
require 'vagrant-proxyconf/cap/util'

describe VagrantPlugins::ProxyConf::Cap::Linux::DockerProxyConf do

  describe '.docker_proxy_conf' do
    let(:machine) { double }
    it "returns the path when docker is installed on Redhat" do
      VagrantPlugins::ProxyConf::Cap::Util.stub(:which) do |_m, c|
        if c == 'docker'
          '/path/to/docker'
        else
          false
        end
      end
      machine.stub_chain(:communicate, :test).and_return(true)

      expect(described_class.docker_proxy_conf(machine)).to eq '/etc/sysconfig/docker'
    end

    it "returns the path when docker is installed on Debian or Ubuntu" do
      VagrantPlugins::ProxyConf::Cap::Util.stub(:which) do |_m, c|
        if c == 'docker'
          '/path/to/docker'
        else
          false
        end
      end
      machine.stub_chain(:communicate, :test).and_return(false)

      expect(described_class.docker_proxy_conf(machine)).to eq '/etc/default/docker'
    end

    it "returns the path when docker.io is installed on Ubuntu 14.04 or higher" do
      VagrantPlugins::ProxyConf::Cap::Util.stub(:which) do |_m, c|
        if c == 'docker.io'
          '/path/to/docker.io'
        else
          false
        end
      end
      machine.stub_chain(:communicate, :test).and_return(false)

      expect(described_class.docker_proxy_conf(machine)).to eq '/etc/default/docker.io'
    end

    it "returns false when docker is not installed" do
      VagrantPlugins::ProxyConf::Cap::Util.stub(which: false)
      expect(described_class.docker_proxy_conf(machine)).to be_false
    end
  end
end
