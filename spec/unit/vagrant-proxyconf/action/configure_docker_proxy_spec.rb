require 'spec_helper'
require 'vagrant-proxyconf/action/configure_docker_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureDockerProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { is_expected.to eq 'docker_proxy' }
  end
end
