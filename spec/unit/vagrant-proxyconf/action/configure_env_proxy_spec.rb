require 'spec_helper'
require 'vagrant-proxyconf/action/configure_env_proxy'
require 'vagrant-proxyconf/config/proxy'
require 'pry'

describe VagrantPlugins::ProxyConf::Action::ConfigureEnvProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { is_expected.to eq 'env_proxy' }
  end

  describe '#disabled?' do
    subject do
      conf = described_class.new(double, double)
      machine = double('machine')
      allow(machine).to receive_message_chain(:config, :proxy, :enabled)
        .and_return(@config_proxy_enabled)
      conf.instance_variable_set(:@machine, machine)
      conf.send(:disabled?)
    end

    context 'when config proxy is enabled' do
      it do
        @config_proxy_enabled = true
        is_expected.to eq false
      end
    end

    context 'when config proxy is not enabled' do
      it do
        @config_proxy_enabled = false
        is_expected.to eq true
      end
    end

    context 'when config proxy is empty string' do
      it do
        @config_proxy_enabled = ''
        is_expected.to eq true
      end
    end

    context 'when target config proxy is enabled' do
      it do
        @config_proxy_enabled = { env: true }
        is_expected.to eq false
      end
    end

    context 'when target config proxy target is not enabled' do
      it do
        @config_proxy_enabled = { env: false }
        is_expected.to eq true
      end
    end

    context 'when other config proxy are not enabled' do
      it do
        @config_proxy_enabled = {
          apt: false,
          chef: false,
          docker: false,
          git: false,
          npm: false,
          pear: false,
          svn: false,
          yum: false
        }
        is_expected.to eq false
      end

    end
  end

  describe "#unconfigure_machine" do
    let(:app) { lambda { |env| } }
    let(:env) { Hash.new }
    let(:machine) { double('machine') }

    context 'when proxy is not enabled' do
      context "and guest is windows" do
        subject do
          conf = described_class.new(app, env)
          allow(conf).to receive(:windows_guest?).and_return(true)
          conf.send(:unconfigure_machine)
        end

        it 'should raise NotImplementedError' do
          expect { subject }.to raise_error(NotImplementedError)
        end
      end

      context "and guest is linux" do
        subject do
          conf = described_class.new(app, env)

          # configure test doubles
          allow(conf).to receive(:windows_guest?).and_return(false)
          conf.instance_variable_set(:@machine, machine)

          @config[:enabled] = false
          proxy = create_config_proxy(@config)

          allow(machine).to receive_message_chain(:config, :proxy).and_return(proxy)
          allow(machine).to receive_message_chain(:config, :public_send).with(:env_proxy).and_return(proxy)
          allow(machine).to receive_message_chain(:communicate, :sudo).with("rm -f /etc/sudoers.d/proxy")
          allow(machine).to receive_message_chain(:communicate, :sudo).with("rm -f /etc/profile.d/proxy.sh")
          allow(machine).to receive_message_chain(:communicate, :sudo).with("rm -f /tmp/vagrant-proxyconf", {:error_check => false})
          allow(machine).to receive_message_chain(:communicate, :upload)
          allow(machine).to receive_message_chain(:communicate, :sudo).with("touch /etc/environment")
          allow(machine).to receive_message_chain(:communicate, :sudo).with("sed -e '/^HTTP_PROXY=/ d\n/^HTTPS_PROXY=/ d\n/^FTP_PROXY=/ d\n/^NO_PROXY=/ d\n/^http_proxy=/ d\n/^https_proxy=/ d\n/^ftp_proxy=/ d\n/^no_proxy=/ d\n' -e '/^$/d' /etc/environment > /etc/environment.new")
          allow(machine).to receive_message_chain(:communicate, :sudo).with("cat /tmp/vagrant-proxyconf >> /etc/environment.new")
          allow(machine).to receive_message_chain(:communicate, :sudo).with("chmod 0644 /etc/environment.new")
          allow(machine).to receive_message_chain(:communicate, :sudo).with("chown root:root /etc/environment.new")
          allow(machine).to receive_message_chain(:communicate, :sudo).with("mv -f /etc/environment.new /etc/environment")
          allow(machine).to receive_message_chain(:communicate, :sudo).with("rm -f /tmp/vagrant-proxyconf").and_return("sib")
          allow(machine).to receive_message_chain(:guest, :capability).with(:env_proxy_conf).and_return("/etc/profile.d/proxy.sh")

          conf.send(:unconfigure_machine)
        end

        it 'should remove file /etc/sudoers.d/proxy, /etc/sudoers.d/proxy.sh and remove configuration from /etc/environment and return true' do
          @config = {
            :ftp      => 'ftp://foo-proxy.foo-domain.com:8080',
            :http     => nil,
            :https    => 'https://foo-proxy.foo-domain.com:8080',
            :no_proxy => 'localhost',
          }

          is_expected.to eq true
        end
      end
    end
  end

end
