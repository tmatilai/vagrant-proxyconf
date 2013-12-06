require 'spec_helper'
require 'vagrant-proxyconf/action/is_enabled'

describe VagrantPlugins::ProxyConf::Action::IsEnabled do
  let(:app) { lambda { |env| } }
  let(:env) { { :machine => machine } }
  let(:machine) do
    double('machine').tap { |machine| machine.stub(:config).and_return(config) }
  end
  let(:config) do
    double('config').tap { |config| config.stub(:proxy => proxy_config) }
  end
  let(:proxy_config) do
    double('proxy_config').tap { |config| config.stub(:enabled => enabled) }
  end

  [false, ''].each do |value|
    context "with `config.proxy.enabled=#{value.inspect}`" do
      let(:enabled) { value }

      it "results to falsy" do
        described_class.new(app, {}).call(env)
        expect(env[:result]).to be_false
      end
    end
  end

  [nil, true, :auto, 'yes please'].each do |value|
    context "with `config.proxy.enabled=#{value.inspect}`" do
      let(:enabled) { value }

      it "results to truthy" do
        described_class.new(app, {}).call(env)
        expect(env[:result]).to be_true
      end
    end
  end

end
