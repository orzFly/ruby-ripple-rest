require File.expand_path("../lib/ripple-rest/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "ripple-rest"
  s.version     = RippleRest::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Yeechan Lu"]
  s.email       = 'ripple-rest@orzfly.com'
  s.homepage    = 'http://github.com/orzFly/ruby-ripple-rest'
  s.summary     = "A ruby wrapper for Ripple REST API."
  s.description = "A ruby wrapper for Ripple REST API."

  s.required_rubygems_version = ">= 1.3.6"

  s.rubyforge_project         = "ripple-rest"

  s.add_dependency "rest-client", "~> 1.6.7"
  s.add_dependency "autoparse", "~> 0.3.3"

  s.files        = Dir["{lib}/**/*.rb", "{lib}/**/*.json", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'

  # s.executables = ["newgem"]

  # s.extensions = "ext/extconf.rb"
end