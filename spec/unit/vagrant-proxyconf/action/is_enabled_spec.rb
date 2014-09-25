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

  [false, ''].each do |value|
    context "with `config.proxy.enabled=#{value.inspect}`" do
      let(:enabled) { value }

      it "results to falsy" do
        described_class.new(app, {}).call(env)
        expect(env[:result]).to be_falsey
      end
    end
  end

  [nil, true, :auto, 'yes please'].each do |value|
    context "with `config.proxy.enabled=#{value.inspect}`" do
      let(:enabled) { value }

      it "results to truthy" do
        described_class.new(app, {}).call(env)
        expect(env[:result]).to be_truthy
      end
    end
  end

end
