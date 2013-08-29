require 'spec_helper'
require 'vagrant-proxyconf/action/configure_apt_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureAptProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { should eq 'apt_proxy' }
  end

end
