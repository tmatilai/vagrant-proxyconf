require 'spec_helper'
require 'vagrant-proxyconf/action/configure_env_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureEnvProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { should eq 'env_proxy' }
  end

end
