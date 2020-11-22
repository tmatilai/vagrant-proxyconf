source 'https://rubygems.org'

gem 'vagrant',
    git: 'https://github.com/hashicorp/vagrant.git',
    tag: ENV.fetch('VAGRANT_VERSION', 'v2.2.14')

gem 'rake'
gem 'rspec', '~> 3.1'
gem 'rspec-its', '~> 1.0'

group :development do
  gem 'guard-rspec'
  gem 'mini_portile2'
  gem 'pry'
  gem 'rb-readline'
  gem 'redcarpet'
  gem 'serverspec'
  gem 'yard', '~> 0.9.11'
end

# when testing our plugin we need to make sure some vagrant plugins are installed
# however, the syntax `Vagrant.require_plugin 'vagrant-proxyconf' was deprecated
# and this is the future for using testing vagrant behind bundler.
# https://stackoverflow.com/questions/19492738/demand-a-vagrant-plugin-within-the-vagrantfile
group :plugins do
  gem 'vagrant-proxyconf', path: __dir__
end
