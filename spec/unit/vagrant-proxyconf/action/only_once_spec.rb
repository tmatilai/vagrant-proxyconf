require 'spec_helper'
require 'vagrant-proxyconf/action/only_once'

describe VagrantPlugins::ProxyConf::Action::OnlyOnce do
  let(:app) { lambda { |env| } }
  let(:env) { {} }

  it "runs the stack first time" do
    received  = nil
    next_step = lambda { |env| received = "value" }

    described_class.new(app, env) do |builder|
      builder.use next_step
    end.call({})

    expect(received).to eq "value"
  end

  it "passes environment to the stack" do
    received  = nil
    next_step = lambda { |env| received = env[:foo] }

    described_class.new(app, env) do |builder|
      builder.use next_step
    end.call({ foo: "value" })

    expect(received).to eq "value"
  end

  it "updates the original environment" do
    next_step = lambda { |env| env[:foo] = "value" }

    described_class.new(app, env) do |builder|
      builder.use next_step
    end.call(env)

    expect(env[:foo]).to eq "value"
  end

  it "runs the same stack only once" do
    count     = 0
    next_step = lambda { |env| count += 1 }
    stack     = lambda { |builder| builder.use next_step }

    described_class.new(app, env, &stack).tap do |instance|
      instance.call(env)
      instance.call(env)
    end
    described_class.new(app, env, &stack).call(env)

    expect(count).to eq 1
  end

  it "runs different stacks" do
    count     = 0
    next_step = lambda { |env| count += 1 }
    stack1    = lambda { |builder| builder.use next_step }
    stack2    = lambda { |builder| builder.use next_step }

    described_class.new(app, env, &stack1).call(env)
    described_class.new(app, env, &stack2).call(env)

    expect(count).to eq 2
  end

  it "calls the next app defore the block by default" do
    received  = nil
    next_app  = lambda { |env| env[:foo] = "value" }
    next_step = lambda { |env| received = env[:foo] }

    described_class.new(next_app, env) do |builder|
      builder.use next_step
    end.call({})

    expect(received).to eq "value"
  end

  it "calls the next app after the block if specified" do
    received  = nil
    next_step = lambda { |env| env[:foo] = "value" }
    next_app  = lambda { |env| received = env[:foo] }

    described_class.new(next_app, env, before: true) do |builder|
      builder.use next_step
    end.call({})

    expect(received).to eq "value"
  end

  it "calls the recover method for the sequence in an error" do
    # Build the steps for the test
    basic_step = Class.new do
      def initialize(app, env)
        @app = app
        @env = env
      end

      def call(env)
        @app.call(env)
      end
    end

    step_a = Class.new(basic_step) do
      def call(env)
        env[:steps] << :call_A
        super
      end

      def recover(env)
        env[:steps] << :recover_A
      end
    end

    step_b = Class.new(basic_step) do
      def call(env)
        env[:steps] << :call_B
        super
      end

      def recover(env)
        env[:steps] << :recover_B
      end
    end

    instance = described_class.new(app, env) do |builder|
      builder.use step_a
      builder.use step_b
    end

    env[:steps] = []
    instance.call(env)
    instance.recover(env)

    expect(env[:steps]).to eq [:call_A, :call_B, :recover_B, :recover_A]
  end
end
