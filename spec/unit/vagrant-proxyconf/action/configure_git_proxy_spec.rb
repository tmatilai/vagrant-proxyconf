require 'spec_helper'
require 'vagrant-proxyconf/action/configure_git_proxy'

describe VagrantPlugins::ProxyConf::Action::ConfigureGitProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { is_expected.to eq 'git_proxy' }
  end

  describe "#configure_machine" do

    context "when configuration is enabled" do
      let(:app) { OpenStruct.new }
      let(:env) { OpenStruct.new }
      let(:machine) { double('machine') }

      context "when supported" do
        subject do
          git_proxy = described_class.new(app, env)
          git_proxy.instance_variable_set(:@machine, machine)

          config = create_config_proxy(
            :enabled  => true,
            :http     => 'http://proxy-server-01.example.com:8080',
            :https    => 'https://proxy-server-01.example.com:8080',
            :no_proxy => 'localhost',
          )

          allow(machine).to receive_message_chain(:config, :proxy).and_return(config)
          allow(machine).to receive_message_chain(:config, :public_send).with(:git_proxy).and_return(config)

          allow(machine).to receive_message_chain(:guest, :capability?).with(:git_proxy_conf).and_return(true)
          allow(machine).to receive_message_chain(:guest, :capability).with(:git_proxy_conf).and_return("/usr/bin/git")

          if git_proxy.send(:disabled?)
            binding.pry
          else
            allow(machine).to receive_message_chain(:communicate, :sudo).with("/usr/bin/git config --system http.proxy http://proxy-server-01.example.com:8080")
            allow(machine).to receive_message_chain(:communicate, :sudo).with("/usr/bin/git config --system https.proxy https://proxy-server-01.example.com:8080")
          end

          git_proxy.send(:configure_machine)
        end

        it 'configures git proxy and returns true' do
          is_expected.to eq true
        end
      end

      context "when not supported" do
        subject do
          git_proxy = described_class.new(app, env)
          git_proxy.instance_variable_set(:@machine, machine)

          allow(machine).to receive_message_chain(:guest, :capability?).with(:git_proxy_conf).and_return(false)
          allow(machine).to receive_message_chain(:guest, :capability).with(:git_proxy_conf).and_return(nil)

          git_proxy.send(:configure_machine)
        end

        it "does not configure the git proxy and returns nil" do
          is_expected.to eq nil
        end
      end

    end

    context "when configuration is disabled" do
    end
  end

  describe "#unconfigure_machine" do
    context "when not supported" do
      let(:app) { OpenStruct.new }
      let(:env) { OpenStruct.new }
      let(:machine) { double('machine') }

      subject do
        git_proxy = described_class.new(app, env)
        git_proxy.instance_variable_set(:@machine, machine)

        allow(machine).to receive_message_chain(:guest, :capability?).with(:git_proxy_conf).and_return(false)
        allow(machine).to receive_message_chain(:guest, :capability).with(:git_proxy_conf).and_return(nil)

        git_proxy.send(:unconfigure_machine)
      end

      it 'returns nil' do
          is_expected.to eq nil
      end
    end

    context "when supported and configuration is disabled" do
      let(:app) { OpenStruct.new }
      let(:env) { OpenStruct.new }
      let(:machine) { double('machine') }

      subject do
        git_proxy = described_class.new(app, env)
        git_proxy.instance_variable_set(:@machine, machine)

        config = create_config_proxy(
          :enabled  => false,
          :http     => 'http://proxy-server-01.example.com:8080',
          :https    => 'https://proxy-server-01.example.com:8080',
          :no_proxy => 'localhost',
        )

        allow(machine).to receive_message_chain(:config, :proxy).and_return(config)
        allow(machine).to receive_message_chain(:config, :public_send).with(:git_proxy).and_return(config)

        allow(machine).to receive_message_chain(:guest, :capability?).with(:git_proxy_conf).and_return(true)
        allow(machine).to receive_message_chain(:guest, :capability).with(:git_proxy_conf).and_return("/usr/bin/git")

        allow(machine).to receive_message_chain(:communicate, :sudo).with("/usr/bin/git config --system --unset-all http.proxy", error_check: false)
        allow(machine).to receive_message_chain(:communicate, :sudo).with("/usr/bin/git config --system --unset-all https.proxy", error_check: false)

        git_proxy.send(:unconfigure_machine)
      end

      it 'configures git proxy and returns true' do
        is_expected.to eq true
      end
    end
  end
end
