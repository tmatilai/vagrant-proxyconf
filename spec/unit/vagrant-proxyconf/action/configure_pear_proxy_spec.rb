require 'spec_helper'
require 'vagrant-proxyconf/action/configure_pear_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigurePearProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { should eq 'pear_proxy' }
  end
end
