source 'https://rubygems.org'

gem 'vagrant',
  git: 'https://github.com/mitchellh/vagrant.git',
  ref: ENV.fetch('VAGRANT_VERSION', 'v1.7.2')

gem 'cane', '~> 2.6'
gem 'coveralls', require: false
gem 'rake', '10.5.0'
gem 'rspec', '~> 3.1'
gem 'rspec-its', '~> 1.0'
gem 'tailor', '~> 1.4'

group :development do
  gem 'guard-rspec'
  gem 'redcarpet'
  gem 'yard', '~> 0.8'
end

group :plugins do
  gem 'vagrant-proxyconf', path: '.'
end
