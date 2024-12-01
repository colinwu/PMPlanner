source 'https://rubygems.org'

gem 'rails', '~> 7.2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'
gem 'responders'
gem 'json'
# Don't forget to rebuild Apache module with each new version of Ruby:
#  passenger-install-apache2-module
gem 'passenger', '~> 6.0', '>= 6.0.23'
# Access an IRB console on exception pages or by using <%= console %> in views
gem 'web-console', group: :development

group :development, :test do
  # do rails generate rspec:install after initial install
  gem 'capistrano', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-passenger', require: false
  gem 'rvm1-capistrano3', require: false
  gem 'scout_apm'
  gem 'rspec-rails'
  gem 'railroady'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'bullet'
  
  # Added 15-Feb-2024 for migration from ruby 2.6 to 3.0
  gem 'webrick', '~> 1.9'
  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  # gem "factory_girl_rails"
  gem "capybara"
  # gem "guard-rspec"
  # gem "mocha"
end
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sassc-rails', '>= 2.1.0'
#  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'turbolinks', '~> 5'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
  gem 'mini_racer', platforms: :ruby
  gem 'uglifier'
  gem 'bootstrap-sass', '~> 3.4.1'
end

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
gem 'jquery-rails'
gem 'csv', '~> 3.3'
# gem 'csv-mapper'
gem 'will_paginate'
gem 'getopt'
gem 'net-ldap'
# gem "best_in_place", git: "https://github.com/mmotherwell/best_in_place"
# gem "best_in_place"
gem 'activerecord-session_store'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

gem 'ed25519'
gem 'bcrypt_pbkdf'

gem "simple_form"
# then rails generate simple_form:install --bootstrap

# Added at 2018-04-15 21:57:58 -0400 by wucolin:
gem "sprockets-rails", "~> 3.2"

gem "terser", "~> 1.2"
