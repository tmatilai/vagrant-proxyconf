source 'https://rubygems.org'

#### Added due to https://groups.google.com/forum/#!topic/vagrant-up/J8J6LmhzBqM/discussion
embedded_locations = %w(/Applications/Vagrant/embedded /opt/vagrant/embedded)

embedded_locations.each do |p|
    ENV['VAGRANT_INSTALLER_EMBEDDED_DIR'] = p if File.directory?(p)
end

unless ENV.key?('VAGRANT_INSTALLER_EMBEDDED_DIR')
    $stderr.puts "Couldn't find a packaged install of vagrant, and we need this"
    $stderr.puts 'in order to make use of the RubyEncoder libraries.'
    $stderr.puts 'I looked in:'
    embedded_locations.each do |p|
        $stderr.puts "  #{p}"
    end
end
#### End Added due to https://groups.google.com/forum/#!topic/vagrant-up/J8J6LmhzBqM/discussion

gem 'vagrant',
    git: 'https://github.com/mitchellh/vagrant.git',
    ref: ENV.fetch('VAGRANT_VERSION', 'v2.2.2')

gem 'rake'
gem 'rspec', '~> 3.1'
gem 'rspec-its', '~> 1.0'

group :development do
  gem 'guard-rspec'
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
