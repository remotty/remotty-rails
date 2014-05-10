class Remotty::Users::SessionsController < Devise::SessionsController
  include ActionController::Flash
  wrap_parameters :user, include: [:email, :password]

  # POST /resource/sign_in
  # 로그인
  def create
    self.resource = warden.authenticate!(:scope => resource_name)

    sign_in(resource_name, resource, store: false)
    yield resource if block_given?

    token = resource.generate_auth_token!('web', request.remote_ip)

    render json: resource.with_token(token)
  end

  # DELETE /resource/sign_out
  # 로그아웃
  def destroy
    user = current_user

    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    if signed_out
      if user && request.headers["X-Auth-Token"].present?
        auth_token = user.auth_tokens.where(token: Digest::SHA512.hexdigest(request.headers["X-Auth-Token"])).first
        auth_token.destroy if auth_token
      end
    end
    yield resource if block_given?

    render nothing: true, status: :no_content
  end

end
