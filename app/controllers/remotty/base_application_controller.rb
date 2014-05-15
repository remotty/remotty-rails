module Remotty::BaseApplicationController
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :configure_permitted_parameters, if: :devise_controller?

    # To resolve the following error: ActionController::UnknownFormat
    include ActionController::StrongParameters

    # To resolve the following error: undefined method `respond_to'
    # http://railscasts.com/episodes/348-the-rails-api-gem?language=ko&view=asciicast
    include ActionController::MimeResponds

    # To resolve the following error: undefined method `default_render'
    # https://github.com/rails-api/rails-api/issues/93
    include ActionController::ImplicitRender
  end

  protected

  def render_error(code = 'ERROR', message = '', status = 400)
    render json: {
      error: {
        code: code,
        message: message
      }
    }, :status => status
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :current_password, :avatar) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :avatar, :password, :password_confirmation, :current_password) }
  end

end
