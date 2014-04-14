require 'spec_helper'
require 'vagrant-proxyconf/action/configure_win_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureWinProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { should eq 'win_proxy' }
  end

end
