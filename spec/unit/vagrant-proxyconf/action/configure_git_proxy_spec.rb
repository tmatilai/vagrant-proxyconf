require 'spec_helper'
require 'vagrant-proxyconf/action/configure_git_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureGitProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { should eq 'git_proxy' }
  end

end
