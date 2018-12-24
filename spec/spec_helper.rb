require 'rspec/its'
require 'vagrant-proxyconf/config/proxy'

PROJECT_DIR = File.absolute_path(File.dirname(__FILE__))

def fixture_file(filename)
  File.join([PROJECT_DIR, "unit", "fixtures", filename])
end

def load_fixture(filename)
  File.read(filename)
end

def create_config_proxy(config={})
  config[:enabled] = true unless config.has_key?(:enabled)
  config[:ftp] ||= nil
  config[:http] ||= nil
  config[:https] ||= nil
  config[:no_proxy] ||= nil

  proxy = VagrantPlugins::ProxyConf::Config::Proxy.new

  # configure proxy
  config.each do |key, value|
    proxy.instance_variable_set("@#{key}", value)
  end

  proxy
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.color = true
  config.tty = true
  config.formatter = :documentation
end
