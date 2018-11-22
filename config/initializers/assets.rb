# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.paths << '/usr/local/rvm/gems/ruby-2.4.1@PM-Planner/gems/bootstrap-sass-3.3.7/assets/javascripts'
Rails.application.config.assets.paths << '/usr/local/rvm/gems/ruby-2.4.1@PM-Planner/gems/bootstrap-sass-3.3.7/assets/stylesheets'
Rails.application.config.assets.paths << '/usr/local/rvm/gems/ruby-2.4.1@PM-Planner/gems/bootstrap-sass-3.3.7/assets/images'
Rails.application.config.assets.paths << '/usr/local/rvm/gems/ruby-2.4.1@PM-Planner/gems/bootstrap-sass-3.3.7/assets/fonts'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )