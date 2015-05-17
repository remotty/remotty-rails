class Remotty::Users::SessionsController < Devise::SessionsController
  include Remotty::Users::BaseController
  include ActionController::Flash
  wrap_parameters :user, include: [:email, :password]
  skip_before_filter :verify_signed_out_user, only: :destroy

  # POST /resource/sign_in
  # email과 password로 로그인
  # 새로운 토큰 생성
  #
  # ==== return
  # * +success+ - 로그인 후 user with token json return
  # * +failure+ - unauthorized with error message
  #
  def create
    self.resource = warden.authenticate!(:scope => resource_name)
    sign_in(resource_name, resource, store: false)
    yield resource if block_given?
    token = resource.generate_auth_token!(auth_source)
    render json: resource.with_token(token)
  end

  # DELETE /resource/sign_out
  # 로그아웃. 로그인이 되어 있지 않아도 에러를 발생하지는 않음
  # 토큰이용시 토큰을 삭제함
  #
  # ==== return
  # * +success+ - no_content
  # * +failure+ - no_content
  #
  def destroy
    user = current_user

    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    if signed_out
      if user && request.headers["X-Auth-Token"].present?
        auth_token = user.auth_tokens.where(token: Digest::SHA512.hexdigest(request.headers["X-Auth-Token"])).first
        auth_token.destroy if auth_token
      end

      session.options[:skip] = true
      response.headers['Set-Cookie'] = 'rack.session=; path=/; expires=Thu, 01-Jan-1970 00:00:00 GMT'
    end
    yield resource if block_given?

    render nothing: true, status: :no_content
  end

  # GET /resource
  # 로그인한 사용자 정보 가져오기
  # * +success+ - current_user json return
  # * +failure+ - unauthentication with error message
  #
  def show
    resource = warden.authenticate(:scope => resource_name)
    if resource
      render json: resource
    else
      render json: {
        error: {
          code: "UNAUTHENTICATION"
        }
      }, :status => :unauthorized
    end
  end
end
