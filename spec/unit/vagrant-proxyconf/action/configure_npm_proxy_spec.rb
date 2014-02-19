require 'spec_helper'
require 'vagrant-proxyconf/action/configure_npm_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureNpmProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { should eq 'npm_proxy' }
  end
end
