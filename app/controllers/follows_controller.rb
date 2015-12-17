class FollowsController < ApplicationController
  before_action :authenticate_user!
  respond_to :js

  def show
  end

  def create
    @foaf = ''
    @type = ''
    if params[:list]
      @foaf = List.find(params[:list]) # todo might be good to secure this
      @type = 'List'
    else
      @foaf = User.find(params[:user]) # todo might be good to secure this
      @type = 'User'
    end
    current_user.follow(@foaf) # todo might be good to secure this
    respond_to do |format|
      format.js {}
    end
    # redirect_to :back # todo remove that and do something better
  end

  def destroy
    @foaf = ''
    @type = ''
    if params[:list]
      @foaf = List.find(params[:list]) # todo might be good to secure this
      @type = 'List'
    else
      @foaf = User.find(params[:user]) # todo might be good to secure this
      @type = 'User'
    end
    current_user.stop_following(@foaf)
    respond_to do |format|
      format.js {}
    end
    # redirect_to :back, status: 303 # todo remove that and do something better, status 303 to prevent double DELETE
  end
end
