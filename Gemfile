source 'https://rubygems.org'

ruby '1.9.3'
gem 'heroku'
gem 'rails', '4.0.0.beta1'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.0.1'
gem 'bootstrap-sass'

group :development, :test do
	gem 'sqlite3'
end

group :production do
	gem 'pg'
	gem 'thin'
end

group :assets do
  gem 'sass-rails',   '~> 4.0.0.beta1'
  gem 'coffee-rails', '~> 4.0.0.beta1'
  gem 'uglifier', '>= 1.0.3'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Deploy with Capistrano
# gem 'capistrano', group: :development