# OmniAuth Exvo

This gem contains the official Exvo strategy for OmniAuth 1.0.

It depends on the [exvo_helpers](https://github.com/Exvo/exvo_helpers) gem for its configuration.

There is also [exvo-auth](https://github.com/Exvo/exvo_auth) gem, which provides additional helper methods, which make both users and app authorizations at Exvo easier.


## Installation

Add to your `Gemfile`:

```ruby
gem 'omniauth-exvo'
```

Then `bundle install`.


## Basic usage

```ruby
use OmniAuth::Builder do
  provider :exvo, ENV['AUTH_CLIENT_ID'], ENV['AUTH_CLIENT_SECRET']
end
```



Copyright © 2011-2012 Exvo.com Development BV, released under the MIT license
