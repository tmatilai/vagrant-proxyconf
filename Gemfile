source 'https://rubygems.org'

gemspec

gem 'vagrant',
  git: 'https://github.com/mitchellh/vagrant',
  ref: ENV.fetch('VAGRANT_VERSION', 'v1.4.3')

gem 'cane', '~> 2.6'
gem 'coveralls', require: false
gem 'rake'
gem 'rspec', '~> 2.11'
gem 'tailor', '~> 1.4'

group :development do
  gem 'guard-rspec'
  gem 'redcarpet'
  gem 'yard', '~> 0.8'
end
