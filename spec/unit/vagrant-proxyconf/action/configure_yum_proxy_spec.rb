require 'pry'
require 'spec_helper'
require 'vagrant-proxyconf/action/configure_yum_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureYumProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { is_expected.to eq 'yum_proxy' }
  end

  describe '#proxy_params' do
    subject do
      action = described_class.new(nil, nil)
      allow(action).to receive(:config) { config }
      action.send(:proxy_params)
    end
    let(:config) { OpenStruct.new(http: http) }

    context "with `false`" do
      let(:http) { false }
      it { is_expected.to eq %q{-v proxy='' -v user='' -v pass=''} }
    end

    context "without userinfo" do
      let(:http) { 'http://proxy:1234/' }
      it { is_expected.to eq %q{-v proxy=http://proxy:1234 -v user='' -v pass=''} }
    end

    context "with userinfo" do
      let(:http) { 'http://foo:bar@myproxy:9876' }
      it { is_expected.to eq %q{-v proxy=http://myproxy:9876 -v user=foo -v pass=bar} }
    end

    context "with special characters" do
      let(:http) { %q{http://x*y:a(b@proxy.com:8080} }
      it { is_expected.to eq %q{-v proxy=http://proxy.com:8080 -v user=x\\*y -v pass=a\\(b} }
    end

    context "with URI encoded special characters" do
      let(:http) { %q{http://foo%25:abc%23123@proxy.com:8080} }
      it { is_expected.to eq %q{-v proxy=http://proxy.com:8080 -v user=foo\% -v pass=abc\#123} }
    end
  end

  describe "#configure_machine" do
    let(:machine) { double('machine') }
    let(:config) { OpenStruct.new }

    context "when not supported" do
      subject do
        yum_proxy = described_class.new(nil, nil)
        yum_proxy.instance_variable_set(:@machine, machine)

        allow(yum_proxy).to receive(:config) { config }
        allow(machine).to receive_message_chain(:guest, :capability?).with(:yum_proxy_conf).and_return(false)
        allow(machine).to receive_message_chain(:guest, :capability).with(:yum_proxy_conf).and_return(nil)

        yum_proxy.send(:configure_machine)
      end

      it 'returns nil' do
        is_expected.to eq nil
      end
    end

    context "when supported" do
      subject do
        yum_proxy = described_class.new(nil, nil)
        yum_proxy.instance_variable_set(:@machine, machine)

        config.http = "http://username:pass@some-yum-proxy-server:8080"

        allow(yum_proxy).to receive(:config) { config }
        allow(machine).to receive_message_chain(:guest, :capability?).with(:yum_proxy_conf).and_return(true)
        allow(machine).to receive_message_chain(:guest, :capability).with(:yum_proxy_conf).and_return("/etc/yum.conf")

        allow(machine).to receive_message_chain(:communicate, :sudo).with("rm -f /tmp/vagrant-proxyconf", error_check: false)
        allow(machine).to receive_message_chain(:communicate, :upload)
        allow(machine).to receive_message_chain(:communicate, :sudo).with("touch /etc/yum.conf")
        allow(machine).to receive_message_chain(:communicate, :sudo).with("gawk -f /tmp/vagrant-proxyconf -v proxy=http://some-yum-proxy-server:8080 -v user=username -v pass=pass /etc/yum.conf > /etc/yum.conf.new")
        allow(machine).to receive_message_chain(:communicate, :sudo).with("chmod 0644 /etc/yum.conf.new")
        allow(machine).to receive_message_chain(:communicate, :sudo).with("chown root:root /etc/yum.conf.new")
        allow(machine).to receive_message_chain(:communicate, :sudo).with("mv -f /etc/yum.conf.new /etc/yum.conf")
        allow(machine).to receive_message_chain(:communicate, :sudo).with("rm -f /tmp/vagrant-proxyconf")

        yum_proxy.send(:configure_machine)
      end

      it 'returns true' do
        is_expected.to eq true
      end

    end
  end

  describe "#unconfigure_machine" do
    let(:machine) { double('machine') }
    let(:config) { OpenStruct.new }

    context "when not supported" do
      subject do
        yum_proxy = described_class.new(nil, nil)
        yum_proxy.instance_variable_set(:@machine, machine)

        allow(yum_proxy).to receive(:config) { config }
        allow(machine).to receive_message_chain(:guest, :capability?).with(:yum_proxy_conf).and_return(false)
        allow(machine).to receive_message_chain(:guest, :capability).with(:yum_proxy_conf).and_return(nil)

        yum_proxy.send(:unconfigure_machine)
      end

      it 'returns nil' do
        is_expected.to eq nil
      end
    end

    context "when supported" do
      subject do
        yum_proxy = described_class.new(nil, nil)
        yum_proxy.instance_variable_set(:@machine, machine)

        config.proxy = OpenStruct.new
        config.proxy.enabled = false
        config.http = "http://username:pass@some-yum-proxy-server:8080"

        allow(yum_proxy).to receive(:config) { config }
        allow(machine).to receive(:config) { config }

        allow(machine).to receive_message_chain(:guest, :capability?).with(:yum_proxy_conf).and_return(true)
        allow(machine).to receive_message_chain(:guest, :capability).with(:yum_proxy_conf).and_return("/etc/yum.conf")

        allow(machine).to receive_message_chain(:communicate, :test).with("grep '^proxy' /etc/yum.conf").and_return(true)
        allow(machine).to receive_message_chain(:communicate, :sudo).with("sed -i.bak -e '/^proxy/d' /etc/yum.conf")

        yum_proxy.send(:unconfigure_machine)
      end

      it 'returns true' do
        is_expected.to eq true
      end
    end
  end

end
