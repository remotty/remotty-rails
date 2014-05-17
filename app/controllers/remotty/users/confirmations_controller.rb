class Remotty::Users::ConfirmationsController < Devise::ConfirmationsController
  include Remotty::Users::BaseController

  # POST /resource/confirmation
  # 토큰을 이용해 이메일 인증 확인
  # 이미 사용한 토큰이거나 잘못된 경우는 에러 반환
  #
  # ==== return
  # * +success+ - no_content
  # * +failure+ - unauthorized with error message
  #
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