require 'spec_helper'
require 'vagrant-proxyconf/cap/linux/env_proxy_conf'

describe VagrantPlugins::ProxyConf::Cap::Linux::EnvProxyConf do

  describe '.env_proxy_conf' do
    let(:subject) { described_class.env_proxy_conf(double) }
    it { is_expected.to eq '/etc/profile.d/proxy.sh' }
  end

end
