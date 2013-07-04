require 'spec_helper'
require 'vagrant-proxyconf/plugin'

describe VagrantPlugins::ProxyConf::Plugin do

  describe ".check_vagrant_version!" do
    let(:min_vagrant_verision) { '1.2.3' }
    let(:err_msg) { /requires Vagrant #{min_vagrant_verision}/ }

    before :each do
      stub_const('VagrantPlugins::ProxyConf::Plugin::MIN_VAGRANT_VERSION', min_vagrant_verision)
      stub_const('Vagrant::VERSION', vagrant_version)
      $stderr.stub(:puts)
    end

    context "on too old Vagrant version" do
      let(:vagrant_version) { '1.1.5' }
      it "raises" do
        expect { described_class.check_vagrant_version! }.to raise_error(err_msg)
      end
      it "warns" do
        $stderr.should_receive(:puts).with(err_msg)
        described_class.check_vagrant_version! rescue nil
      end
    end

    context "on exact required Vagrant version" do
      let(:vagrant_version) { min_vagrant_verision }
      it "does not raise" do
        expect { described_class.check_vagrant_version! }.not_to raise_error
      end
    end

    context "on newer Vagrant version" do
      let(:vagrant_version) { '1.3.5' }
      it "does not raise" do
        expect { described_class.check_vagrant_version! }.not_to raise_error
      end
    end
  end

end
