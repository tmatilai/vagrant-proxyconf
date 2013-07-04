require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'tailor/rake_task'

task :default => [:test, :tailor]

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

Tailor::RakeTask.new do |task|
  task.file_set('lib/**/*.rb', 'code') do |style|
    style.max_line_length 100, level: :warn
    style.max_line_length 140, level: :error
  end
  task.file_set('spec/**/*.rb', 'tests') do |style|
    style.max_line_length 120, level: :warn
    # allow vertical alignment of `let(:foo) { block }` blocks
    style.spaces_before_lbrace 1, level: :off
  end
end
