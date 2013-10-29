guard 'rspec'  do
  watch(%r{^spec/unit/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})          { |m| "spec/unit/#{m[1]}_spec.rb" }
  watch(%r{^(resources/.+)\.})       { |m| "spec/unit/vagrant-proxyconf/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')       { "spec" }
end
