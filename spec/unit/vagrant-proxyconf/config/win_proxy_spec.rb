require 'spec_helper'
require 'vagrant-proxyconf/config/win_proxy'

describe VagrantPlugins::ProxyConf::Config::WinProxy do
  let(:instance) { described_class.new }
  before(:each) { ENV.delete('VAGRANT_WIN_HTTP_PROXY') }
end
