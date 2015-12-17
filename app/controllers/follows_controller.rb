class FollowsController < ApplicationController
  before_action :authenticate_user!
  respond_to :js

  def create
    @list = List.find(params[:list])
    current_user.follow(@list) # todo might be good to secure this
    redirect_to :back # todo remove that and do something better
  end

  def destroy
    @list = List.find(params[:list]) # todo might be good to secure this
    current_user.stop_following(@list)
    redirect_to :back, status: 303 # todo remove that and do something better
  end
end
