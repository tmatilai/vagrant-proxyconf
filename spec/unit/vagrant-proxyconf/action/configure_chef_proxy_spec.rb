require 'spec_helper'
require 'vagrant-proxyconf/action/configure_chef_proxy'
require 'ostruct'

describe VagrantPlugins::ProxyConf::Action::ConfigureChefProxy do

  describe '#configure_chef' do
    let(:chef)   { OpenStruct.new }
    let(:config) { OpenStruct.new }
    let(:machine) { double('machine') }


    def configure_chef
      action = described_class.new(nil, nil)
      action.instance_variable_set(:@machine, machine)
      config.enabled = true if config.enabled.nil?
      allow(machine).to receive_message_chain(:config, :proxy).and_return(config)
      allow(action).to receive(:config) { config }
      action.send(:configure_chef, chef)
    end

    context "with no configurations" do
      it "leaves all to nil" do
        configure_chef
        expect(chef.http_proxy).to be_nil
        expect(chef.http_proxy_user).to be_nil
        expect(chef.http_proxy_pass).to be_nil
        expect(chef.https_proxy).to be_nil
        expect(chef.https_proxy_user).to be_nil
        expect(chef.https_proxy_pass).to be_nil
        expect(chef.no_proxy).to be_nil
      end
    end

    context "with specified default configurations" do
      before :each do
        config.http  = 'http://bar:baz@foo:1234'
        config.https = false

        configure_chef
      end

      it "configures chef" do
        expect(chef.http_proxy).to  eq 'http://foo:1234'
        expect(chef.http_proxy_user).to eq 'bar'
        expect(chef.http_proxy_pass).to eq 'baz'
        expect(chef.https_proxy).to be_nil
        expect(chef.https_proxy_user).to be_nil
        expect(chef.https_proxy_pass).to be_nil
      end
    end

    context "with specified default configurations in URI encoded" do
      before :each do
        config.http  = 'http://bar%23:baz%25@foo:1234'
        config.https = false

        configure_chef
      end

      it "configures chef" do
        expect(chef.http_proxy).to  eq 'http://foo:1234'
        expect(chef.http_proxy_user).to eq 'bar#'
        expect(chef.http_proxy_pass).to eq 'baz%'
        expect(chef.https_proxy).to be_nil
        expect(chef.https_proxy_user).to be_nil
        expect(chef.https_proxy_pass).to be_nil
      end
    end

    context "with specified chef configurations" do
      before :each do
        chef.http_proxy = 'http://proxy:8080/'
        chef.no_proxy   = 'localhost'

        config.http     = 'http://foo:@default:7070/'
        config.https    = 'http://sslproxy:3128/'

        configure_chef
      end

      it "won't override chef config" do
        expect(chef.http_proxy).to  eq 'http://proxy:8080/'
        expect(chef.http_proxy_user).to be_nil
        expect(chef.http_proxy_pass).to be_nil
        expect(chef.no_proxy).to eq 'localhost'
      end

      it "configures unset proxies" do
        expect(chef.https_proxy).to eq 'http://sslproxy:3128'
      end
    end

    context 'when user wants to disable the configured chef proxy and does not unset the configured proxy variables' do
      before :each do
        config.enabled  = false
        config.http     = 'http://username:secretpass@my-proxy-host.example.com:8080'
        config.https    = 'https://username:secretpass@my-proxy-host.example.com:8080'
        config.no_proxy = 'localhost,*.example.com'

        configure_chef
      end

      it 'should unconfigure chef proxy' do
        expect(config.enabled).to eq false
        expect(config.http).to eq 'http://username:secretpass@my-proxy-host.example.com:8080'
        expect(config.https).to eq 'https://username:secretpass@my-proxy-host.example.com:8080'
        expect(config.no_proxy).to eq 'localhost,*.example.com'

        expect(chef.http_proxy).to be_nil
        expect(chef.http_proxy_user).to be_nil
        expect(chef.http_proxy_pass).to be_nil
        expect(chef.https_proxy).to be_nil
        expect(chef.https_proxy_user).to be_nil
        expect(chef.https_proxy_pass).to be_nil
        expect(chef.no_proxy).to be_nil
      end
    end

  end

end
