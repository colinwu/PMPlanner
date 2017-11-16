json.extract! news, :id, :note, :activate, :urgent, :created_at, :updated_at
json.url news_url(news, format: :json)
