require 'spec_helper'
require 'vagrant-proxyconf/cap/windows/env_proxy_conf'

describe VagrantPlugins::ProxyConf::Cap::Windows::EnvProxyConf do

  describe '.env_proxy_conf' do
    let(:subject) { described_class.env_proxy_conf(double) }
    it { is_expected.to eq '/proxy.conf' }
  end

end
