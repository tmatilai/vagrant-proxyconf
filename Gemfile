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
  gem 'yard', '~> 0.8'
end

group :plugins do
  gem 'vagrant-proxyconf', path: '.'
  gem 'vagrant-vbguest', '~> 0.17'
  gem 'vagrant-omnibus', '1.5.0'
end
