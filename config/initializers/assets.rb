# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '2.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.paths << '/usr/local/rvm/gems/ruby-3.0.0@PM-Planner-Rails7/gems/bootstrap-sass-3.4.1/assets/javascripts'
Rails.application.config.assets.paths << '/usr/local/rvm/gems/ruby-3.0.0@PM-Planner-Rails7/gems/bootstrap-sass-3.4.1/assets/stylesheets'
Rails.application.config.assets.paths << '/usr/local/rvm/gems/ruby-3.0.0@PM-Planner-Rails7/gems/bootstrap-sass-3.4.1/assets/images'
Rails.application.config.assets.paths << '/usr/local/rvm/gems/ruby-3.0.0@PM-Planner-Rails7/gems/bootstrap-sass-3.4.1/assets/fonts'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
