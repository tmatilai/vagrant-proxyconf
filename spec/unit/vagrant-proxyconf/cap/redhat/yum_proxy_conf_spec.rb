require 'spec_helper'
require 'vagrant-proxyconf/cap/redhat/yum_proxy_conf'

describe VagrantPlugins::ProxyConf::Cap::Redhat::YumProxyConf do

  describe '.yum_proxy_conf' do
    let(:subject) { described_class.yum_proxy_conf(double) }
    it { should eq '/etc/yum.conf' }
  end

end
