module VagrantPlugins
  # Base module for Vagrant Proxyconf plugin
  module ProxyConf
    # @param name [String] the resource file name
    # @return [String] the absolute path to the resource file
    def self.resource(name)
      File.join(resource_root, name)
    end

    private

    # @return [String] the absolute åath to the resource directory
    def self.resource_root
      File.expand_path('../../../resources', __FILE__)
    end
  end
end
