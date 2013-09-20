# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-proxyconf/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-proxyconf"
  spec.version       = VagrantPlugins::ProxyConf::VERSION
  spec.authors       = ["Teemu Matilainen"]
  spec.email         = ["teemu.matilainen@iki.fi"]
  spec.description   = "A Vagrant plugin that configures the virtual machine to use proxy servers"
  spec.summary       = spec.description
  spec.homepage      = "http://tmatilai.github.io/vagrant-proxyconf/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
