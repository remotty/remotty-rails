class Users::PasswordsController < Devise::PasswordsController
  include Remotty::Users::BaseController

  # POST /resource/password
  # email주소를 이용해서 패스워드 변경 요청 메일을 발송함
  #
  # ==== return
  # * +success+ - no_content
  # * +failure+ - validation error message
  #
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      render nothing: true, status: :no_content
    else
      render_error 'VALIDATION_ERROR', resource.errors.full_messages.first
    end
  end

  # PUT /resource/password
  # 토큰을 이용한 패스워드 변경
  # 성공시 자동으로 로그인을 시도하고 토큰을 생성함
  #
  # ==== return
  # * +success+ - 로그인 후 user with token json return
  # * +failure+ - unauthorized with error message
  #
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      sign_in resource_name, resource, :store => false

      token = resource.generate_auth_token!(auth_source)
      render json: resource.with_token(token)
    else
      render_error 'UNAUTHORIZED',
                   resource.errors.full_messages.first,
                   :unauthorized
    end
  end

end
