require 'spec_helper'
require 'vagrant-proxyconf/cap/debian/apt_proxy_conf'

describe VagrantPlugins::ProxyConf::Cap::Debian::AptProxyConf do

  describe '.apt_proxy_conf' do
    let(:subject) { described_class.apt_proxy_conf(double) }
    it { should eq '/etc/apt/apt.conf.d/01proxy' }
  end

end
