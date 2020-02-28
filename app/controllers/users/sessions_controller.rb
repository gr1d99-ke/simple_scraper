# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super
    setup_subscriptions
  end

  # DELETE /resource/sign_out
  def destroy
    cleanup_subscriptions
    super
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  private

  def cleanup_subscriptions
    ActionCable.server.disconnect(current_user: current_user)
    cookies.delete(:user_id)
  end

  def setup_subscriptions
    cookies.encrypted[:user_id] = current_user.id
  end
end
