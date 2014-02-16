require 'spec_helper'
require 'vagrant-proxyconf/config/git_proxy'

describe VagrantPlugins::ProxyConf::Config::GitProxy do
  let(:instance) { described_class.new }
  before(:each) { ENV.delete('VAGRANT_GIT_HTTP_PROXY') }
end
