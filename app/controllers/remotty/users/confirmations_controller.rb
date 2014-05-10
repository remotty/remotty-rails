class Remotty::Users::ConfirmationsController < Devise::ConfirmationsController

  # POST /resource/confirmation
  # 이메일 인증 확인
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      render nothing: true, status: :no_content
    else
      render_error 'UNAUTHORIZED',
                   resource.errors.full_messages.first,
                   :unauthorized
    end
  end

end