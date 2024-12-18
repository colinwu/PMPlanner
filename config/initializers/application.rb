
module PmPlanner
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.time_zone = 'Eastern Time (US & Canada)'
    config.encoding = "utf-8"
    config.active_support.escape_html_entities_in_json = true
    config.assets.enabled = true
    config.active_storage.service = :local
    # config.assets.precompile = ["manifest.js"]
  end
end
