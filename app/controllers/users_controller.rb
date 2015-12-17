class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: []
  before_action :set_user, only: [:show, :edit, :update]

  def index
    if user_signed_in?
      @users = User.all - [current_user]
    else
      @users = ''
    end
  end

  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:id)
    end

end
