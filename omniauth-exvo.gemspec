# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omniauth-exvo/version"

Gem::Specification.new do |gem|
  gem.name        = "omniauth-exvo"
  gem.version     = Omniauth::Exvo::VERSION
  gem.authors     = ["Paweł Gościcki"]
  gem.email       = ["pawel.goscicki@gmail.com"]
  gem.homepage    = ""
  gem.summary     = %q{TODO: Write a gem summary}
  gem.description = %q{TODO: Write a gem description}

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency 'omniauth', '~> 1.0'
  gem.add_dependency 'omniauth-oauth2', '~> 1.0'
  gem.add_dependency 'exvo_helpers', '>= 0.1.0'

  gem.add_development_dependency 'rspec', '>= 2.8'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'webmock'

  gem.add_development_dependency 'guard', ['>= 0.10.0']
  gem.add_development_dependency 'guard-rspec', ['>= 0.6.0']
  gem.add_development_dependency "rb-fsevent"
  gem.add_development_dependency "rb-inotify"

  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "simplecov-rcov"
end
