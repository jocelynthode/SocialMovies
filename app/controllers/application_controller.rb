class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  protected

  def omdb_query(imdb_id)
    redis_key = 'omdb_' + imdb_id
    response = redis.get(redis_key)
    unless response
      response = HTTP.get('http://www.omdbapi.com/', params: {
          i: imdb_id,
          plot: 'full',
          r: 'json'
      })
      redis.set(redis_key, response.to_s)
    end

    data = JSON.parse(response, symbolize_names: true)
    status = data[:Error] ? false : true
    [status, data]
  end

  def redis
    if @redis
      @redis
    else
      @redis = Redis.new
    end
  end
end