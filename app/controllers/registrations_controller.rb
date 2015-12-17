class RegistrationsController < Devise::RegistrationsController
  after_action :create_default, only: [:create]

  protected

  def create_default
    List.create({name: 'Watch It Later', user_id: @user.id}) if resource.persisted?
  end
end