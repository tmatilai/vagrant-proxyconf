require 'spec_helper'
require 'vagrant-proxyconf/config/key'

describe VagrantPlugins::ProxyConf::Config::Key do

  describe '.new' do
    context 'without options' do
      subject       { described_class.new(name) }
      let(:name)    { :mykey }
      its(:name)    { should eq name }
      its(:default) { should be_nil }
      its(:env_var) { should be_nil }
    end

    context 'with string name' do
      subject       { described_class.new(name) }
      let(:name)    { 'mykey' }
      its(:name)    { should eq name.to_sym }
    end

    context 'with default value' do
      subject       { described_class.new(name, default: default) }
      let(:name)    { :foo }
      let(:default) { 'bar' }
      its(:default) { should eq default }
    end

    context 'with env_var' do
      subject       { described_class.new(name, env_var: env_var) }
      let(:name)    { :key }
      let(:env_var) { 'baz' }
      its(:env_var) { should eq env_var }
    end
  end

  describe '#value_from_env_var' do
    before :each do
      %w[foo_bar BAZ].each { |k| ENV.delete(k) }
    end
    let(:instance) { described_class.new(name, default: default, env_var: env_var) }
    let(:name)     { 'the_key' }
    let(:default)  { nil }
    let(:env_var)  { nil }

    shared_examples 'env_var' do
      it 'returns :default without block' do
        expect(instance.value_from_env_var).to eq default
      end
      it 'yields with the :default value' do
        expect { |b| instance.value_from_env_var(&b) }.to yield_with_args default
      end
      it 'returns the value from the block' do
        ret = 'block_default'
        expect(instance.value_from_env_var { ret }).to eq ret
      end
    end

    context 'without env_var' do
      context 'with a specified default' do
        let(:default)  { 'param_default' }
        include_examples 'env_var'
      end

      context 'and without default' do
        include_examples 'env_var'
      end
    end

    context 'with env_var' do
      before :each do
        ENV['foo_bar'] = 'from_env_var'
        ENV['BAZ']     = 'second_env_var'
      end
      let(:env_var) { 'BAZ' }
      let(:default) { 'the_default' }

      it 'returns value of the environment variable' do
        expect(instance.value_from_env_var).to eq ENV['BAZ']
      end
      it 'does not yield' do
        expect { |b| instance.value_from_env_var(&b) }.not_to yield_control
      end
    end
  end

end
