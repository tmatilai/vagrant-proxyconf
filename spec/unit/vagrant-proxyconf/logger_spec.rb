require 'spec_helper'
require 'vagrant-proxyconf/logger'

describe VagrantPlugins::ProxyConf do

  describe '.logger' do
    subject { described_class.logger }

    it { is_expected.to be_a Log4r::Logger }

    it "always returns the same instance" do
      expect(subject).to be described_class.logger
    end
  end

end
