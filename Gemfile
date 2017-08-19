source 'https://rubygems.org'

gem 'vagrant',
  git: 'https://github.com/mitchellh/vagrant.git',
  ref: ENV.fetch('VAGRANT_VERSION', 'v1.9.7')

gem 'rake'
gem 'rspec', '~> 3.1'
gem 'rspec-its', '~> 1.0'

group :development do
  gem 'guard-rspec'
  gem 'redcarpet'
  gem 'yard', '~> 0.8'
end

group :plugins do
  gem 'vagrant-proxyconf', path: File.dirname(__FILE__)
end
