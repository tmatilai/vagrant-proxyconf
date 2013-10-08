require 'log4r'

module VagrantPlugins
  # Base module for Vagrant Proxyconf plugin
  module ProxyConf
    # @return [Log4r::Logger] the logger instance for this plugin
    def self.logger
      @logger ||= Log4r::Logger.new('vagrant::proxyconf')
    end
  end
end
