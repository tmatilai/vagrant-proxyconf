source 'https://rubygems.org'

gem 'vagrant',
    git: 'https://github.com/mitchellh/vagrant.git',
    ref: ENV.fetch('VAGRANT_VERSION', 'v2.2.2')

gem 'rake'
gem 'rspec', '~> 3.1'
gem 'rspec-its', '~> 1.0'

group :development do
  gem 'guard-rspec'
  gem 'redcarpet'
  gem 'yard', '~> 0.9.11'
end

group :plugins do
  gem 'vagrant-proxyconf', path: __dir__
end
