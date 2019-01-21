require 'spec_helper'
require 'vagrant-proxyconf/action/is_enabled'

describe VagrantPlugins::ProxyConf::Action::IsEnabled do
  let(:app) { lambda { |env| } }
  let(:env) { { :machine => machine } }
  let(:machine) do
    double('machine').tap do |machine|
      allow(machine).to receive(:config) { config }
    end
  end
  let(:config) do
    double('config').tap do |config|
      allow(config).to receive(:proxy) { proxy_config }
    end
  end
  let(:proxy_config) do
    double('proxy_config').tap do |config|
      allow(config).to receive(:enabled) { enabled }
    end
  end

  describe "#has_proxy_env_var?" do
    subject do
      is_enabled = described_class.new(app, env)

      is_enabled.send(:has_proxy_env_var?, var)
    end

    context "when HTTP_PROXY is set in the environment and config.proxy.enabled=true" do
      let(:enabled) { true }
      let(:var) { 'HTTP_PROXY' }

      before :each do
        ENV[var] = 'http://localhost:8888'
      end

      after :each do
        ENV[var] = nil
      end

      it { expect(ENV[var]).to eq 'http://localhost:8888' }

      it { is_expected.to eq true }
    end

    context "when HTTPS_PROXY="" is set in the environment and config.proxy.enabled=true" do
      let(:enabled) { true }
      let(:var) { 'HTTPS_PROXY' }

      before :each do
        ENV[var] = ''
      end

      after :each do
        ENV[var] = nil
      end

      it { expect(ENV[var]).to eq '' }
      it { is_expected.to eq false }
    end

  end

  describe "#plugin_disabled?" do

    subject do
      is_enabled = described_class.new(app, env)
      is_enabled.send(:plugin_disabled?, env[:machine].config.proxy)
    end

    context "given config.proxy.enabled=false" do
      let(:enabled) { false }

      it { is_expected.to eq true }
    end

    context "given config.proxy.enabled=''" do
      let(:enabled) { "" }

      it { is_expected.to eq true }
    end

    context "given config.proxy.enabled=nil" do
      let(:enabled) { false }

      it { is_expected.to eq true }
    end

    context "given config.proxy.enabled={}" do
      let(:enabled) { false }

      it { is_expected.to eq true }
    end

    context "given config.proxy.enabled={:foo => 'bar'}" do
      let(:enabled) do
        {:foo => 'bar'}
      end

      it { is_expected.to eq false }
    end

    context "given config.proxy.enabled=true" do
      let(:enabled) { true }

      it { is_expected.to eq false }
    end

    context "given config.proxy.enabled='http://localhost:8080'" do
      let(:enabled) { 'http://localhost:8080' }

      it { is_expected.to eq false }
    end

  end

  describe "#plugin_enabled?" do
    subject do
      is_enabled = described_class.new(app, env)
      is_enabled.send(:plugin_enabled?, env[:machine].config.proxy)
    end

    context "when config.proxy.enabled=false and ENV['HTTP_PROXY']='http://localhost:8888'" do
      let(:enabled) { false }
      let(:var) { 'HTTP_PROXY' }

      before :each do
        ENV[var] = 'http://localhost:8888'
      end

      after :each do
        ENV[var] = nil
      end

      it { is_expected.to eq false }
    end

  end

  describe "#call" do
    [false, '', {}, nil].each do |value|
      context "with `config.proxy.enabled=#{value.inspect}`" do
        let(:enabled) { value }

        it "results to falsy" do
          described_class.new(app, {}).call(env)
          expect(env[:result]).to be_falsey
        end
      end
    end

    [true, :auto, 'yes please', {:foo => 'yes'}].each do |value|
      context "with `config.proxy.enabled=#{value.inspect}` and HTTP_PROXY=http://localhost:8888" do
        let(:enabled) { value }
        let(:var) { 'HTTP_PROXY' }

        before :each do
          ENV[var] = 'http://localhost:8888'
        end

        after :each do
          ENV[var] = nil
        end

        it "results to truthy" do
          described_class.new(app, {}).call(env)
          expect(env[:result]).to be_truthy
        end
      end
    end

    [true, :auto, 'yes please', {:foo => 'yes'}].each do |value|
      context "with `config.proxy.enabled=#{value.inspect}` and HTTP_PROXY=''" do
        let(:enabled) { value }
        let(:var) { 'HTTP_PROXY' }

        before :each do
          ENV[var] = ''
        end

        after :each do
          ENV[var] = nil
        end

        it "results to truthy" do
          described_class.new(app, {}).call(env)
          expect(env[:result]).to be_falsey
        end
      end
    end

  end

end
