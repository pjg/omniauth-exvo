# OmniAuth Exvo

This gem contains the official Exvo strategy for OmniAuth 1.0.

There is also [exvo-auth](https://github.com/Exvo/exvo_auth) gem, which provides additional helper methods, which make both users and app authorizations at Exvo easier.


## Installation

Add to your `Gemfile`:

```ruby
gem 'omniauth-exvo'
```

Then `bundle install`.


## Basic usage

Set both `ENV['AUTH_CLIENT_ID']` and `ENV['AUTH_CLIENT_SECRET']` somewhere (vhost configuration, heroku config, `config/environments/*` or even `config/application.rb`).

```ruby
use OmniAuth::Builder do
  provider :exvo, ENV['AUTH_CLIENT_ID'], ENV['AUTH_CLIENT_SECRET']
end
```

If you'd like to use Exvo's staging auth, you need to pass the `:client_options` hash to override the default:

```ruby
use OmniAuth::Builder do
  provider :exvo, ENV['AUTH_CLIENT_ID'], ENV['AUTH_CLIENT_SECRET'], :client_options => { :site => 'http://staging.auth.exvo.com' }
end
```




Copyright © 2011-2012 Exvo.com Development BV, released under the MIT license
