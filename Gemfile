source 'https://rubygems.org'

ruby '2.2.3'

gem 'rails',                    '~> 4.2'
gem 'thin',                     '~> 1.6.3'
gem 'sass-rails',               '~> 4.0.3'
gem 'uglifier',                 '>= 1.3.0'
gem 'coffee-rails',             '~> 4.0.0'
gem 'jquery-rails',             '~> 4.0.4'
gem 'turbolinks',               '~> 2.5.3'
gem 'jbuilder',                 '~> 2.3.1'
gem 'handlebars_assets',        '~> 0.20.2'
gem 'activeadmin',              github: 'activeadmin'
gem 'active_admin_import',      '~> 2.1.2'
gem 'geocoder',                 '~> 1.2.9'
gem 'rpush',                    '~> 2.5.0'
gem 'http_logger',              '~> 0.5.1'
gem 'sinch_sms',                '~> 2.1'
gem 'colorize',                 '~> 0.7.7'
gem 'bootstrap-sass',           '~> 3.3.1'
gem 'simple_form',              '~> 3.1.0'
gem 'googlestaticmap',          git: 'https://github.com/ReseauEntourage/googlestaticmap.git'
gem 'momentjs-rails',           '~> 2.10.3'
gem 'shorturl',                 '~> 1.0.0'
gem 'attr_encrypted',           '~> 1.3.4'
gem 'mailchimp-api',            '~> 2.0.6'
gem 'pg',                       '~> 0.18.2'
gem 'newrelic_rpm',             '~> 3.12.1.298'
gem 'kaminari',                 '~> 0.16.3'
gem 'redis',                    '~> 3.2.1'
gem 'bcrypt',                   '~> 3.1.10'
gem 'sentry-raven',             '~> 0.13.3'
gem 'sidekiq',                  '~> 3.4.1'

group :development, :test do
  gem 'byebug',                 '~> 5.0.0'
  gem 'spring',                 '~> 1.3.6'
  gem 'spring-commands-rspec',  '~> 1.0.4'
end

group :development do
  gem 'better_errors',          '~> 2.1.1'
  gem 'binding_of_caller',      '~> 0.7.2'
  gem 'dredd-rack',             '~> 0.7.0'
  gem 'dotenv-rails',           '~> 2.0.2'
  gem 'rack-mini-profiler',     '~> 0.9.8' #enable by requesting any page with '?pp=enable'
  gem 'pry-rails',              '~> 0.3.4'
  gem 'quiet_assets',           '~> 1.1.0'
end

group :test do
  gem 'guard-rspec',            '~> 4.6.3'
  gem 'rspec-rails',            '~> 3.1'
  gem 'shoulda-matchers',       '~> 2.8.0'
  gem 'simplecov',              '~> 0.10.0'
  gem 'nyan-cat-formatter',     '~> 0.11'
  gem 'timecop',                '~> 0.8.0'
  gem 'factory_girl_rails',     '~> 4.5.0'
  gem 'webmock',                '~> 1.20.4'
  gem 'coveralls',              require: false
  gem 'fakeredis',              '~> 0.5.0'
end

group :production do
  gem 'rails_12factor',         '~> 0.0.3'
  gem 'puma',                   '~> 2.12.2'
end