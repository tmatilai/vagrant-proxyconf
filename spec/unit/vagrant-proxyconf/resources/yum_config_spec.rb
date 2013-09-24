require 'spec_helper'
require 'unit/support/fixture'
require 'vagrant-proxyconf/resource'

describe 'resources/yum_config.awk' do
  def configure(config = {})
    cmd = "gawk -f #{VagrantPlugins::ProxyConf.resource('yum_config.awk')}"
    cmd << %w[proxy user pass].map { |var| " -v #{var}=#{config[var.to_sym].to_s.shellescape}" }.join
    cmd << " #{fixture_path(old_conf)}"
    `#{cmd}`
  end

  context "with empty old conf" do
    let(:old_conf) { 'empty' }

    it "adds the specified proxy" do
      expect(configure(proxy: 'http://proxy:1234')).to eq fixture('yum_only_proxy.conf')
    end

    it "adds proxy and userinfo" do
      conf = { proxy: 'http://proxy.example.com:3128/', user: 'foo', pass: 'bar' }
      expect(configure(conf)).to eq fixture('yum_only_proxy_and_userinfo.conf')
    end

    it "adds disabled proxy if proxy not specified" do
      expect(configure(user: 'foo')).to eq fixture('yum_only_disabled_proxy.conf')
    end

  end

  context "with only main section" do
    let(:old_conf) { 'yum_only_main.conf' }

    it "adds the specified proxy" do
      conf = { proxy: 'http://proxy.example.com:3128/', user: 'foo', pass: 'bar' }
      expect(configure(conf)).to eq fixture('yum_only_main_with_proxy.conf')
    end

    it "adds disabled proxy if proxy not specified" do
      expect(configure(pass: 'bar')).to eq fixture('yum_only_main_with_disabled_proxy.conf')
    end
  end

  context "with main and repository sections" do
    context "without old proxy conf" do
      let(:old_conf) { 'yum_with_repository.conf' }

      it "adds the specified proxy" do
        conf = { proxy: 'http://proxy.example.com:3128/', user: 'foo', pass: 'bar' }
        expect(configure(conf)).to eq fixture('yum_with_repository_and_proxy.conf')
      end

      it "adds disabled proxy if proxy not specified" do
        expect(configure).to eq fixture('yum_with_repository_and_disabled_proxy.conf')
      end
    end

    context "with old proxy conf" do
      let(:old_conf) { 'yum_with_repository_and_proxy.conf' }

      it "replaces existing proxy" do
        conf = { proxy: 'http://newproxy:9876', user: 'baz' }
        expect(configure(conf)).to eq fixture('yum_with_repository_and_new_proxy.conf')
      end

      it "disables existing proxy" do
        conf = { proxy: '', user: 'baz' }
        expect(configure(conf)).to eq fixture('yum_with_repository_and_disabled_proxy.conf')
      end
    end

    context "without userinfo" do
      let(:old_conf) { 'yum_with_repository_and_proxy_without_userinfo.conf' }

      it "replaces existing proxy and adds userinfo" do
        conf = { proxy: 'http://proxy.example.com:3128/', user: 'foo', pass: 'bar' }
        expect(configure(conf)).to eq fixture('yum_with_repository_and_proxy.conf')
      end

    end
  end

end
