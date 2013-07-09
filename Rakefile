require 'bundler/gem_tasks'
require 'cane/rake_task'
require 'rspec/core/rake_task'
require 'tailor/rake_task'

task :default => [:test, :quality]

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

Cane::RakeTask.new(:cane) do |task|
  task.style_measure = 100
  task.options[:color] = true
  # TODO: Fix documentation and remove
  task.max_violations = 5
end

desc 'Run all quality tasks'
task :quality => [:cane, :tailor]

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
