require 'spec_helper'
require 'vagrant-proxyconf/config/proxy'
require 'vagrant-proxyconf/action/configure_docker_proxy'

def mock_write_docker_config(machine)
  allow(machine).to receive_message_chain(:communicate, :sudo).with("rm -f /tmp/vagrant-proxyconf", error_check: false)
  allow(machine).to receive_message_chain(:communicate, :upload)
  allow(machine).to receive_message_chain(:communicate, :sudo).with("touch /etc/default/docker")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("sed -e '/^HTTP_PROXY=/ d\n/^http_proxy=/ d\n/^HTTPS_PROXY=/ d\n/^https_proxy=/ d\n/^NO_PROXY=/ d\n/^no_proxy=/ d\n' /etc/default/docker > /etc/default/docker.new")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("cat /tmp/vagrant-proxyconf >> /etc/default/docker.new")
  allow(machine).to receive_message_chain(:communicate, :test).with("diff /etc/default/docker.new /etc/default/docker")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("chmod 0644 /etc/default/docker.new")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("chown root:root /etc/default/docker.new")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("mv -f /etc/default/docker.new /etc/default/docker")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("kill -HUP `pgrep -f 'docker'` || systemctl restart docker || service docker restart || /etc/init.d/docker restart")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("rm -f /tmp/vagrant-proxyconf /etc/default/docker.new")
end

def mock_update_docker_client_config(machine)
  allow(machine).to receive_message_chain(:communicate, :upload)
  allow(machine).to receive_message_chain(:communicate, :sudo).with("mv /tmp/vagrant-proxyconf-docker-config.json /etc/docker/config.json")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("chown root:root /etc/docker/config.json")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("rm -f /tmp/vagrant-proxyconf-docker-config.json")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("sed -i.bak -e '/^DOCKER_CONFIG/d' /etc/environment")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("echo DOCKER_CONFIG=/etc/docker >> /etc/environment")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("mkdir -p /etc/docker")
  allow(machine).to receive_message_chain(:communicate, :sudo).with("chown root:root /etc/docker")
end

def mock_update_docker_systemd_config(machine)
end

describe VagrantPlugins::ProxyConf::Action::ConfigureDockerProxy do

  describe '#config_name' do
    subject { described_class.new(double, double).config_name }
    it      { is_expected.to eq 'docker_proxy' }
  end

  describe "#configure_machine" do

    context 'when docker is not supported' do
      let(:app) { OpenStruct.new }
      let(:env) { OpenStruct.new }
      let(:machine) { double('machine') }

      def configure_docker_proxy
        docker_proxy = described_class.new(app, env)
        docker_proxy.instance_variable_set(:@machine, machine)

        allow(machine).to receive_message_chain(:guest, :capability?).with(:docker_proxy_conf).and_return(false)

        @docker_proxy = docker_proxy
      end

      before :each do
        configure_docker_proxy
      end

      it 'return nil' do
        expect(@docker_proxy.send(:configure_machine)).to be_nil
      end
    end

    context "when docker is supported" do
      let(:app) { OpenStruct.new }
      let(:env) { OpenStruct.new }
      let(:machine) { double('machine') }

      def configure_docker_proxy(fixture)
        docker_proxy = described_class.new(app, env)
        docker_proxy.instance_variable_set(:@machine, machine)

        # #docker_client_config_path mock
        fixture = docker_proxy.send(:tempfile, load_fixture(fixture)).path
        docker_proxy.instance_variable_set(:@docker_client_config_path, fixture)

        # #supported? mock
        allow(machine).to receive_message_chain(:guest, :capability?).with(:docker_proxy_conf).and_return(true)
        allow(machine).to receive_message_chain(:guest, :capability).with(:docker_proxy_conf).and_return('/etc/default/docker')

        # #config mock
        config = create_config_proxy(
          :enabled  => true,
          :http     => 'http://proxy-server-01.example.com:8080',
          :https    => 'https://proxy-server-01.example.com:8080',
          :no_proxy => 'localhost',
        )

        allow(machine).to receive_message_chain(:config, :proxy).and_return(config)
        allow(machine).to receive_message_chain(:config, :public_send).with(:docker_proxy).and_return(config)

        mock_write_docker_config(machine)
        mock_update_docker_client_config(machine)

        # update_docker_client_config mock
        allow(docker_proxy).to receive(:supports_config_json?).and_return(true)
        allow(docker_proxy).to receive(:supports_systemd?).and_return(false)

        @docker_proxy = docker_proxy
      end

      context 'and when /etc/docker/config.json has proxy configuration' do
        before :each do
          fixture = fixture_file("docker_client_config_json_enabled_proxy")
          configure_docker_proxy(fixture)
          allow(machine).to receive_message_chain(:communicate, :sudo).with(
            "sed -e '/^export HTTP_PROXY=/ d\n/^export http_proxy=/ d\n/^export HTTPS_PROXY=/ d\n/^export https_proxy=/ d\n/^export NO_PROXY=/ d\n/^export no_proxy=/ d\n' /etc/default/docker > /etc/default/docker.new"
          )
        end

        it 'update /etc/docker/config.json' do
            expect(@docker_proxy.send(:configure_machine)).to eq true
        end
      end

      context 'and when configuring systemd' do
        let(:app) { OpenStruct.new }
        let(:env) { OpenStruct.new }
        let(:machine) { double('machine') }

        def configure_docker_proxy(fixture)
          docker_proxy = described_class.new(app, env)
          docker_proxy.instance_variable_set(:@machine, machine)

          # #docker_client_config_path mock
          fixture = docker_proxy.send(:tempfile, load_fixture(fixture)).path
          docker_proxy.instance_variable_set(:@docker_client_config_path, fixture)

          # #supported? mock
          allow(machine).to receive_message_chain(:guest, :capability?).with(:docker_proxy_conf).and_return(true)
          allow(machine).to receive_message_chain(:guest, :capability).with(:docker_proxy_conf).and_return('/etc/default/docker')

          # #config mock
          config = create_config_proxy(
            :enabled  => true,
            :http     => 'http://proxy-server-01.example.com:8080',
            :https    => 'https://proxy-server-01.example.com:8080',
            :no_proxy => 'localhost',
          )

          allow(machine).to receive_message_chain(:config, :proxy).and_return(config)
          allow(machine).to receive_message_chain(:config, :public_send).with(:docker_proxy).and_return(config)
          allow(machine).to receive_message_chain(:communicate, :test).with('command -v systemctl').and_return(true)

          mock_write_docker_config(machine)
          mock_update_docker_client_config(machine)

          @docker_proxy = docker_proxy
        end

        context 'when directory: /etc/systemd/system/docker.service.d does not exist' do

          before :each do
            fixture = fixture_file("docker_client_config_json_enabled_proxy")
            configure_docker_proxy(fixture)

            # update_docker_client_config mock
            allow(@docker_proxy).to receive(:supports_config_json?).and_return(false)
            allow(@docker_proxy).to receive(:supports_systemd?).and_return(true)

            # systemd_config mocking
            allow(machine).to receive_message_chain(:communicate, :sudo).with("mkdir -p /etc/systemd/system/docker.service.d")
            allow(machine).to receive_message_chain(:communicate, :upload).with(@docker_proxy.instance_variable_get(:@docker_systemd_config), "/tmp")
            allow(machine).to receive_message_chain(:communicate, :sudo).with('chown -R 0:0 /etc/systemd/system/docker.service.d/')
            allow(machine).to receive_message_chain(:communicate, :sudo).with('chmod 0644 /etc/systemd/system/docker.service.d/http-proxy.conf')
            allow(machine).to receive_message_chain(:communicate, :test).with('command -v systemctl').and_return(false)
            allow(machine).to receive_message_chain(:communicate, :test).with('diff -Naur /etc/systemd/system/docker.service.d/http-proxy.conf /tmp/vagrant-proxyconf-docker-systemd-config').and_return(false)
            allow(machine).to receive_message_chain(:communicate, :sudo).with('mv /tmp/vagrant-proxyconf-docker-systemd-config /etc/systemd/system/docker.service.d/http-proxy.conf')
            allow(machine).to receive_message_chain(:communicate, :sudo).with('systemctl daemon-reload')
            allow(machine).to receive_message_chain(:communicate, :sudo).with('systemctl restart docker')
          end

          it 'should create directory: /etc/systemd/system/docker.service.d' do
            expect(@docker_proxy.send(:update_docker_systemd_config)).to eq true
          end

        end
      end

    end
  end

  describe "#docker_client_config_path" do
    let(:machine) { double('machine') }

    context "when not supported" do
      subject do
        docker_proxy = described_class.new(nil, nil)
        docker_proxy.instance_variable_set(:@machine, machine)

        allow(docker_proxy).to receive(:supports_config_json?).and_return(false)

        # #supported? mock
        allow(machine).to receive_message_chain(:guest, :capability?).with(:docker_proxy_conf).and_return(true)
        allow(machine).to receive_message_chain(:guest, :capability).with(:docker_proxy_conf).and_return('/etc/default/docker')

        docker_proxy.send(:docker_client_config_path)
      end

      it { is_expected.to eq nil }
    end

    context "when supported" do
      context "when /etc/docker/config.json exists" do
        subject do
          docker_proxy = described_class.new(nil, nil)
          docker_proxy.instance_variable_set(:@machine, machine)
          docker_proxy.instance_variable_set(:@docker_client_config_path, nil)

          allow(docker_proxy).to receive(:supports_config_json?).and_return(true)

          allow(machine).to receive_message_chain(:communicate, :test).with("[ -f /etc/docker/config.json ]").and_return(true)
          allow(machine).to receive_message_chain(:communicate, :sudo).with("chmod 0644 /etc/docker/config.json")
          allow(machine).to receive_message_chain(:communicate, :download)

          docker_proxy.send(:docker_client_config_path)
        end

        it { expect(File.exists?(subject)).to eq true }
      end

      context "when /etc/docker/config.json does not exist" do
        subject do
          docker_proxy = described_class.new(nil, nil)
          docker_proxy.instance_variable_set(:@machine, machine)
          docker_proxy.instance_variable_set(:@docker_client_config_path, nil)

          allow(docker_proxy).to receive(:supports_config_json?).and_return(true)

          allow(machine).to receive_message_chain(:communicate, :test).with("[ -f /etc/docker/config.json ]").and_return(false)

          docker_proxy.send(:docker_client_config_path)
        end

        it do
          expect(File.exists?(subject)).to eq true
          expect(File.read(subject)).to eq "{}"
        end
      end
    end
  end

  describe "#update_docker_client_config" do
    let(:app) { OpenStruct.new }
    let(:env) { OpenStruct.new }
    let(:machine) { double('machine') }

    context "when #supports_config_json? returns false" do

      it 'return nil' do
        docker_proxy = described_class.new(app, env)
        docker_proxy.instance_variable_set(:@machine, machine)

        allow(docker_proxy).to receive(:supports_config_json?).and_return(false)

        # #supported? mock
        allow(machine).to receive_message_chain(:guest, :capability?).with(:docker_proxy_conf).and_return(true)
        allow(machine).to receive_message_chain(:guest, :capability).with(:docker_proxy_conf).and_return('/etc/default/docker')

        expect(docker_proxy.send(:update_docker_client_config)).to eq nil
      end

    end

    context "when #docker_client_config_path returns nil" do
     it 'return nil' do
        docker_proxy = described_class.new(app, env)
        docker_proxy.instance_variable_set(:@machine, machine)

        # mock a result that looks like no proxy is configured for the config.json
        allow(docker_proxy).to receive(:supports_config_json?).and_return(true)
        allow(docker_proxy).to receive(:docker_client_config_path).and_return(nil)

        # #supported? mock
        allow(machine).to receive_message_chain(:guest, :capability?).with(:docker_proxy_conf).and_return(true)
        allow(machine).to receive_message_chain(:guest, :capability).with(:docker_proxy_conf).and_return('/etc/default/docker')

        expect(docker_proxy.send(:update_docker_client_config)).to eq nil
      end
    end

    context "when /etc/docker/config.json is supported" do

      context "when configuration is disabled" do
        it do
          docker_proxy = described_class.new(app, env)
          docker_proxy.instance_variable_set(:@machine, machine)

          # mock a result that looks like proxy is configured for the config.json
          fixture = fixture_file("docker_client_config_json_enabled_proxy")
          fixture_content = load_fixture(fixture)
          config_path = docker_proxy.send(:tempfile, fixture_content).path

          docker_proxy.instance_variable_set(:@docker_client_config_path, config_path)

          allow(docker_proxy).to receive(:supports_config_json?).and_return(true)
          allow(docker_proxy).to receive(:disabled?).and_return(true)

          mock_update_docker_client_config(machine)

          expected = JSON.pretty_generate(
            {
              "proxies" => {
                "default" => Hash.new
              }
            }
          )
          expect(docker_proxy.send(:update_docker_client_config)).to eq expected
        end
      end

      context "when configuration is enabled" do
        it do
          docker_proxy = described_class.new(app, env)
          docker_proxy.instance_variable_set(:@machine, machine)

          # simulate config
          config = create_config_proxy(
            :enabled  => true,
            :http     => 'http://proxy-server-01.example.com:8080',
            :https    => 'https://proxy-server-01.example.com:8080',
            :no_proxy => 'localhost',
          )

          allow(machine).to receive_message_chain(:config, :proxy).and_return(config)
          allow(machine).to receive_message_chain(:config, :public_send).with(:docker_proxy).and_return(config)

          # mock a result that looks like no proxy is configured for the config.json
          fixture = fixture_file("docker_client_config_json_no_proxy")
          fixture_content = load_fixture(fixture)
          config_path = docker_proxy.send(:tempfile, fixture_content).path

          docker_proxy.instance_variable_set(:@docker_client_config_path, config_path)

          allow(docker_proxy).to receive(:supports_config_json?).and_return(true)
          allow(docker_proxy).to receive(:disabled?).and_return(false)

          mock_update_docker_client_config(machine)
          expected = JSON.pretty_generate(
            {
              "proxies" => {
                "default" => {
                  "httpProxy"  => "http://proxy-server-01.example.com:8080",
                  "httpsProxy" => "https://proxy-server-01.example.com:8080",
                  "noProxy"    => "localhost",
                }
              }
            }
          )

          expect(docker_proxy.send(:update_docker_client_config)).to eq expected
        end
      end
    end
  end

  describe "#unconfigure_machine" do

    context "when not supported" do
      let(:app) { OpenStruct.new }
      let(:env) { OpenStruct.new }
      let(:machine) { double('machine') }

      subject do
        docker_proxy = described_class.new(app, env)
        docker_proxy.instance_variable_set(:@machine, machine)

        allow(machine).to receive_message_chain(:guest, :capability?).with(:docker_proxy_conf).and_return(false)
        allow(machine).to receive_message_chain(:guest, :capability).with(:docker_proxy_conf).and_return(nil)

        docker_proxy.send(:unconfigure_machine)
      end

      it 'return nil' do
        is_expected.to eq nil
      end
    end

    context "when supported" do
      context "when config is enabled" do
        let(:app) { OpenStruct.new }
        let(:env) { OpenStruct.new }
        let(:machine) { double('machine') }

        subject do
          docker_proxy = described_class.new(app, env)
          docker_proxy.instance_variable_set(:@machine, machine)
          docker_proxy.instance_variable_set(:@version, [18, 9, 0])

          fixture = fixture_file("docker_client_config_json_enabled_proxy")
          config_path = docker_proxy.send(:tempfile, load_fixture(fixture)).path
          docker_proxy.instance_variable_set(:@docker_client_config_path, config_path)

          # to isolate this test, we turn of support for systemd
          allow(docker_proxy).to receive(:supports_systemd?).and_return(false)

          allow(machine).to receive_message_chain(:guest, :capability?).with(:docker_proxy_conf).and_return(true)
          allow(machine).to receive_message_chain(:guest, :capability).with(:docker_proxy_conf).and_return('/etc/default/docker')

          # #config mock
          allow(machine).to receive_message_chain(:config, :proxy, :enabled).and_return(true)
          config = create_config_proxy(
            :enabled  => true,
            :http     => 'http://proxy-server-01.example.com:8080',
            :https    => 'https://proxy-server-01.example.com:8080',
            :no_proxy => 'localhost',
          )
          allow(machine).to receive_message_chain(:config, :proxy).and_return(config)
          allow(machine).to receive_message_chain(:config, :public_send).with(:docker_proxy).and_return(config)


          # mock write_docker_config
          mock_write_docker_config(machine)

          # mock update_docker_client_config
          mock_update_docker_client_config(machine)

          docker_proxy.send(:unconfigure_machine)
        end

        it 'return true' do
          is_expected.to eq true
        end
      end

      context "when config is disabled" do
        let(:app) { OpenStruct.new }
        let(:env) { OpenStruct.new }
        let(:machine) { double('machine') }

        subject do
          docker_proxy = described_class.new(app, env)
          docker_proxy.instance_variable_set(:@machine, machine)
          docker_proxy.instance_variable_set(:@version, [18, 9, 0])

          # to isolate this test, we turn of support for systemd
          allow(docker_proxy).to receive(:supports_systemd?).and_return(false)

          fixture = fixture_file("docker_client_config_json_enabled_proxy")
          config_path = docker_proxy.send(:tempfile, load_fixture(fixture)).path
          docker_proxy.instance_variable_set(:@docker_client_config_path, config_path)

          allow(machine).to receive_message_chain(:guest, :capability?).with(:docker_proxy_conf).and_return(true)
          allow(machine).to receive_message_chain(:guest, :capability).with(:docker_proxy_conf).and_return('/etc/default/docker')

          # #config mock
          allow(machine).to receive_message_chain(:config, :proxy, :enabled?).and_return(false)
          config = create_config_proxy(
            :enabled  => false,
            :http     => 'http://proxy-server-01.example.com:8080',
            :https    => 'https://proxy-server-01.example.com:8080',
            :no_proxy => 'localhost',
          )
          allow(machine).to receive_message_chain(:config, :proxy).and_return(config)
          allow(machine).to receive_message_chain(:config, :public_send).with(:docker_proxy).and_return(config)

          allow(docker_proxy).to receive(:disabled?).and_return(true)

          mock_write_docker_config(machine)
          mock_update_docker_client_config(machine)

          docker_proxy.send(:unconfigure_machine)
        end

        it 'should disable proxy configuration' do
          is_expected.to eq true
        end
      end

    end
  end

  describe "#docker_version" do
    let(:machine) { double('machine') }

    context "when not supported" do
      subject do
        docker_proxy = described_class.new(nil, nil)
        docker_proxy.instance_variable_set(:@machine, machine)

        # #supported? mock
        allow(machine).to receive_message_chain(:guest, :capability?).with(:docker_proxy_conf).and_return(false)
        allow(machine).to receive_message_chain(:guest, :capability).with(:docker_proxy_conf).and_return(nil)

        docker_proxy.send(:docker_version)
      end

      it { is_expected.to eq nil }
    end

    context "when supported parse" do
      subject do
        docker_proxy = described_class.new(nil, nil)
        docker_proxy.instance_variable_set(:@machine, machine)

        # #supported? mock
        allow(machine).to receive_message_chain(:guest, :capability?).with(:docker_proxy_conf).and_return(true)
        allow(machine).to receive_message_chain(:guest, :capability).with(:docker_proxy_conf).and_return("/etc/default/docker")

        allow(machine).to receive_message_chain(:communicate, :execute).with('docker --version').and_yield(@type, @version)

        docker_proxy.send(:docker_version)
      end

      context '"Docker version 17.05.0-ce, build 89658be"' do
        it do
          @type = :stdout
          @version = "Docker version 17.05.0-ce, build 89658be"

          is_expected.to eq [17, 5, 0]
        end
      end

      context '"Docker version 18.09.0, build 4d60db4"' do
        it do
          @type = :stdout
          @version = "Docker version 18.09.0, build 4d60db4"

          is_expected.to eq [18, 9, 0]
        end
      end
    end
  end

  describe "#supports_config_json?" do
    let(:machine) { double('machine') }

    context "when not supported" do
      subject do
        docker_proxy = described_class.new(nil, nil)
        docker_proxy.instance_variable_set(:@machine, machine)

        # #supported? mock
        allow(machine).to receive_message_chain(:guest, :capability?).with(:docker_proxy_conf).and_return(false)
        allow(machine).to receive_message_chain(:guest, :capability).with(:docker_proxy_conf).and_return(nil)

        docker_proxy.send(:supports_config_json?)
      end

      it 'returns false' do
        is_expected.to eq false
      end
    end

    context "when supported" do
      subject do
        docker_proxy = described_class.new(nil, nil)
        docker_proxy.instance_variable_set(:@machine, machine)
        docker_proxy.instance_variable_set(:@version, @version)

        # #supported? mock
        allow(machine).to receive_message_chain(:guest, :capability?).with(:docker_proxy_conf).and_return(true)
        allow(machine).to receive_message_chain(:guest, :capability).with(:docker_proxy_conf).and_return("/etc/defualt/docker")

        docker_proxy.send(:supports_config_json?)
      end

      it 'given docker_version is 18.09.1, return true' do
        @version = [18, 9, 1]
        is_expected.to eq true
      end

      it 'given docker_version is 17.07, return true' do
        @version = [17, 7, 0]
        is_expected.to eq true
      end

      it 'given docker_version is 17.06, return false' do
        @version = [17, 6, 0]
        is_expected.to eq false
      end
    end

  end

end
