require 'spec_helper'
require 'vagrant-proxyconf/action/base'
require 'vagrant-proxyconf/action/configure_apt_proxy'

class MyBase < VagrantPlugins::ProxyConf::Action::Base

  def config_name
    'my_base'
  end

  private

  def configure_machine
  end

  def unconfigure_machine
  end

end

def create_base(machine, env)
  base = MyBase.new(nil, env)
  base.instance_variable_set(:@machine, machine)

  expect(base.config_name).to eq 'my_base'

  base
end

describe MyBase do
  let(:machine) { double('machine') }

  describe "#skip?" do
    let(:config) { OpenStruct.new }
    let(:env) { OpenStruct.new }

    subject do
      base = create_base(machine, env)
      allow(machine).to receive_message_chain(:config, :proxy) { config }

      base.send(:skip?)
    end

    context "when attempting to configure a app proxy that is not defined" do
      before(:each) do
        config.enabled = {:foobar => false}
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq false }
    end

    context "when config.proxy.enabled[:my_base] = false" do
      before(:each) do
        config.enabled = {:my_base => false}
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq true }
    end

    context "when config.proxy.enabled[:my_base] = true" do
      before(:each) do
        config.enabled = {:my_base => true}
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq false }
    end

    context "when config.proxy.enabled[:my_base] = {}" do
      before(:each) do
        config.enabled = {}
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq false }
    end


    context "when config.proxy.enabled[:my_base] = {:enabled => false, :skip => false}" do
      before(:each) do
        config.enabled = {
          :my_base => {
            :enabled => false,
            :skip    => false,
          }
        }
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq false }
    end

    context "when config.proxy.enabled[:my_base] = {:enabled => true, :skip => false}" do
      before(:each) do
        config.enabled = {
          :my_base => {
            :enabled => true,
            :skip    => false,
          }
        }
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq false }
    end

    context "when config.proxy.enabled[:my_base] = {:enabled => true, :skip => true}" do
      before(:each) do
        config.enabled = {
          :my_base => {
            :enabled => true,
            :skip    => true,
          }
        }
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq true }
    end

    context "when config.proxy.enabled[:my_base] = {:enabled => false, :skip => true}" do
      before(:each) do
        config.enabled = {
          :my_base => {
            :enabled => false,
            :skip    => true,
          }
        }
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq true }
    end

    context "when config.proxy.enabled = false" do
      before(:each) do
        config.enabled = false
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq true }
    end

    context "when config.proxy.enabled = true " do
      before(:each) do
        config.enabled = true
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq false }
    end

    context "when config.proxy.enable[:my_base] = {:enabled => true} and :skip key is missing" do
      before(:each) do
        config.enabled = {
          :my_base => {
            :enabled => false,
          },
        }
        config.http    = 'http://foo-proxy-server:8080'
        config.https   = 'http://foo-prxoy-server:8080'
        config.ftp     = 'ftp://foo-proxy-server:8080'
      end

      it { is_expected.to eq false }
    end
  end

end
