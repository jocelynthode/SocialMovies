json.array!(@movies) do |movie|
  json.extract! movie, :id, :mid
  json.url movie_url(movie, format: :json)
end
