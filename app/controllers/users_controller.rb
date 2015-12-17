class UsersController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    if user_signed_in?
      @users = User.all
    else
      @users = ''
    end
  end

  def show
  end
  
end
