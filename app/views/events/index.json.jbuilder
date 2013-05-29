json.array!(@events) do |event|
  json.extract! event, :name, :start_at, :end_at
  json.url event_url(event, format: :json)
end