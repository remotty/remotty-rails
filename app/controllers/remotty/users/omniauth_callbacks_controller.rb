class Remotty::Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include ActionController::Flash

  def all
    auth = request.env['omniauth.auth']
    user = from_omniauth(auth)
    @ret = {}

    if user
      if user.persisted?
        sign_in(:user, user, store: false)
        token = user.generate_auth_token!('web', request.remote_ip)

        @ret = user.with_token(token)
      else
        @ret = {
          error: {
            code: "OAUTH_LOGIN_ERROR",
            message: "email required!"
          }
        }
      end
    else
      @ret = {
        error: {
          code: "OAUTH_LOGIN_ERROR",
          message: "oauth login error!"
        }
      }
    end

    render :inline => "<script>window.opener.oauthCallback(#{@ret.to_json}); window.close();</script>"
  end

  def failure
    @ret = {
      error: {
        code: OmniAuth::Utils.camelize(failed_strategy.name),
        message: failure_message
      }
    }

    render :inline => "<script>window.opener.oauthCallback(#{@ret.to_json}); window.close();</script>"
  end

  alias_method :facebook, :all
  alias_method :twitter, :all

  private

  def from_omniauth(auth)
    if auth.provider && auth.uid # 인증정보가 있으면..
      oauth = OauthAuthentication.find_by_provider_and_uid(auth.provider, auth.uid)
      if oauth # 이미 가입되어 있다면 oauth 정보를 갱신함
        oauth.set_oauth_info(auth)
        oauth.save

        return oauth.user
      else # 기존 정보가 없음!
        if auth.info.email.present? # 이메일이 있으면 가입 또는 연동
          user = User.find_or_create_by(email: auth.info.email) do |u|
            u.name = auth.info.name || auth.info.email
            u.password = Devise.friendly_token[0,20]
            u.set_oauth_avatar(auth)
            u.confirm!
            u.save
          end
          user.confirm! # 인증 대기 중이면 바로 인증시켜버림

          # oauth 정보 생성
          oauth = OauthAuthentication.new({
                                            user_id:user.id,
                                            provider:auth.provider,
                                            uid:auth.uid
                                          })
          oauth.set_oauth_info(auth)
          oauth.save

          return user
        else
          return User.new({ name: auth.info.name })
        end
      end
    end

    nil
  end
end