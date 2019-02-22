# -*- mode: ruby -*-
# vi: set ft=ruby :

source 'https://rubygems.org'

gem 'dockerspec', '~> 0.5.0'
gem 'rake', '~> 12.3.2'
gem 'rubocop', '~> 0.58.2', require: false
gem 'rubocop-rspec', '~> 1.22.2', require: false

# We add these because they need cross-platform distinctions
gem 'jaro_winkler', '~> 1.5.2', platforms: %i[jruby ruby]
gem 'mini_portile2', '~> 2.4.0', platforms: :ruby
gem 'nokogiri', '~> 1.10.1', platforms: %i[jruby ruby]
gem 'websocket-driver', '~> 0.7.0', platforms: %i[jruby ruby]

#
# To make the Gemfile.lock cross-platform, run the following after `bundle install`
#   `bundle lock --add-platform ruby` (if on JRuby)
#   `bundle lock --add-platform jruby` (if on C Ruby
#
