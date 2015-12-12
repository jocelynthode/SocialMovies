class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  protected

  def omdb_query(imdb_id)
    response = HTTP.get('http://www.omdbapi.com/', params: {
        i: imdb_id,
        plot: 'full',
        r: 'json'
    })
    data = JSON.parse(response, symbolize_names: true)
    status = data[:Error] ? false : true
    [status, data]
  end


end