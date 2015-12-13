class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!

  #TODO refactor the map functions
  def index
    if user_signed_in?
      @movies = current_user.recommended_movies.empty? ? Movie.top(10).map(&:retrieve!) : current_user.recommended_movies.map(&:retrieve!)
    else
      @movies = Movie.top(10).map(&:retrieve!)
    end

  end
end
