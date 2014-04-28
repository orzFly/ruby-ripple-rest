require "bundler"
Bundler.setup

require 'rake/testtask'
require "rspec/core/rake_task"
Rspec::Core::RakeTask.new(:spec)

gemspec = eval(File.read("ripple-rest.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["ripple-rest.gemspec"] do
  system "gem build ripple-rest.gemspec"
  system "gem install ripple-rest-#{RippleRest::VERSION}.gem"
end
