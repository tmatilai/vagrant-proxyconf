require 'spec_helper'
require 'vagrant-proxyconf/cap/linux/git_proxy_conf'

describe VagrantPlugins::ProxyConf::Git::Linux::EnvProxyConf do

  describe '.git_proxy_conf' do
    let(:subject) { described_class.git_proxy_conf(double) }
    it { should eq 0 }
  end

end
