json.array!(@friendships) do |friendship|
  json.extract! friendship, 
  json.url friendship_url(friendship, format: :json)
end