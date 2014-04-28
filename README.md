ripple-rest gem
===============

[![Gem Version](https://badge.fury.io/rb/ripple-rest.svg)](http://badge.fury.io/rb/ripple-rest)

This is a client that interacts with the Ripple network using the Ripple REST APIs.

The documentation can be found at http://rubydoc.info/github/orzfly/ruby-ripple-rest/master/frames.

Example
-------

```ruby
require 'ripple-rest'

RippleRest.setup "http://localhost:5990/"
acc = RippleRest::Account.new "r###########", "s###########"
p acc.payments.create("r###########", "1+XRP").submit
p acc.settings
p acc.trustlines
```


