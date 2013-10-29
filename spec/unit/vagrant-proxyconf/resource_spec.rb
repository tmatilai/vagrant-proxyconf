require 'spec_helper'
require 'vagrant-proxyconf/resource'

describe VagrantPlugins::ProxyConf do
  describe ".resource" do
    let(:root_dir) { File.expand_path('../../../..', __FILE__) }

    it "returns path to the specified file" do
      expect(described_class.resource('foo.txt').to_s).to eq File.join(root_dir, 'resources', 'foo.txt')
    end
  end

end
