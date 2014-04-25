require "bundler"
Bundler.setup

require "rspec"
require "ripple-rest"
require "support/matchers"

Rspec.configure do |config|
  config.include RippleRest::Spec::Matchers
end