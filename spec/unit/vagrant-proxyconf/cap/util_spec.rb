require 'spec_helper'
require 'vagrant-proxyconf/cap/util'

describe VagrantPlugins::ProxyConf::Cap::Util do

  describe '.which' do
    let(:machine) { double }
    let(:communicator) { double }

    before do
      allow(machine).to receive(:communicate) { communicator }
    end

    it "returns the path when the command is installed" do
      expect(communicator).to receive(:execute).
        with('command -v foo', error_check: false).
        and_yield(:stdout, "/path/to/foo\n").
        and_yield(:stdout, "PROMPT\n").
        and_yield(:stderr, "not foo\n").
        and_return(0)
      expect(described_class.which(machine, 'foo')).to eq '/path/to/foo'
    end

    it "returns false when the command is not installed" do
      expect(communicator).to receive(:execute).
        with('command -v bar', error_check: false).
        and_return(1)
      expect(described_class.which(machine, 'bar')).to be_falsey
    end
  end

end
