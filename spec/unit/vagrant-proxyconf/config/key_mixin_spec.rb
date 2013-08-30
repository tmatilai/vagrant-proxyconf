require 'spec_helper'
require 'vagrant-proxyconf/config/key_mixin'

describe VagrantPlugins::ProxyConf::Config::KeyMixin do

  class TestConfig < Vagrant.plugin('2', :config)
    include VagrantPlugins::ProxyConf::Config::KeyMixin
    key :foo
    key :bar
  end

  class TestDefaultConfig < Vagrant.plugin('2', :config)
    include VagrantPlugins::ProxyConf::Config::KeyMixin
    key :foo
    key :baz
  end

  let(:config) do
    TestConfig.new.tap do |c|
      c.foo = foo
      c.bar = bar
    end
  end

  let(:default) do
    TestDefaultConfig.new.tap do |c|
      c.foo = default_foo
      c.baz = default_baz
    end
  end

  let(:foo) { nil }
  let(:bar) { nil }
  let(:default_foo) { nil }
  let(:default_baz) { nil }

  describe '#merge_defaults' do
    subject { config.merge_defaults(default) }

    context 'with no configuration' do
      it { should be_kind_of config.class }
      it { should_not be config }

      its(:foo) { should be_nil }
      its(:bar) { should be_nil }
    end

    context 'without default configuration' do
      let(:foo) { 'tricky' }
      let(:bar) { 'tracks' }

      its(:foo) { should eq foo }
      its(:bar) { should eq bar }
    end

    context 'with default configuration' do
      let(:foo) { 'tricky' }
      let(:bar) { 'tracks' }
      let(:default_foo) { 'billy' }
      let(:default_baz) { 'bam-bam' }

      its(:foo) { should eq foo }
      its(:bar) { should eq bar }
    end

    context 'with a mixture configuration' do
      let(:bar) { 'tracks' }
      let(:default_foo) { 'billy' }

      its(:foo) { should eq default_foo }
      its(:bar) { should eq bar }
    end

    context 'with only default configuration' do
      let(:default_foo) { 'billy' }
      let(:default_baz) { 'bam-bam' }

      its(:foo) { should eq default_foo }
      its(:bar) { should be_nil }
    end
  end

end
