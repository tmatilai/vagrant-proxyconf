require 'spec_helper'
require 'vagrant-proxyconf/config/svn_proxy'

describe VagrantPlugins::ProxyConf::Config::SvnProxy do
  let(:instance) { described_class.new }
  before(:each) { ENV.delete('VAGRANT_SVN_HTTP_PROXY') }
end
