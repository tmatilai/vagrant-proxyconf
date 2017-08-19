require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task :default => :test

# Remove 'install' task as the gem is installed to Vagrant, not to system
Rake::Task[:install].clear

namespace :test do
  RSpec::Core::RakeTask.new('unit') do |task|
    task.pattern = 'spec/unit/**/*_spec.rb'
  end
end
desc "Run all tests"
task :test => ['test:unit']
task :spec => :test

desc "Update gh-pages"
task 'gh-pages' do
  require 'tmpdir'

  rev = `git rev-parse HEAD`.chomp
  Dir.mktmpdir do |clone|
    sh %Q{git clone --branch gh-pages "#{File.expand_path('..', __FILE__)}" "#{clone}"}
    Dir.chdir(clone) do
      sh %Q{_bin/update "#{rev}"}
    end
  end
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  # gem not installed on the CI server
end
