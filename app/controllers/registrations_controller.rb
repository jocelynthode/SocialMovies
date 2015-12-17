class RegistrationsController < Devise::RegistrationsController
  after_action :create_default, only: [:create]

  protected

  def create_default
    if resource.persisted?
      List.create({name: 'Watch It Later', user_id: @user.id})
      List.new({name: 'Bookmarks', user_id: @user.id})
    end
  end
end