require 'spec_helper'
require 'vagrant-proxyconf/action/configure_svn_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureSvnProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { is_expected.to eq 'svn_proxy' }
  end

end
