class Remotty::Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Remotty::Users::BaseController
  include ActionController::Flash

  # omniauth callback 처리
  # 정보에 따라 유저를 만들던가 연결하던가 추가 정보를 입력받도록 에러를 리턴함
  #
  def all
    # omniauth에서 생성한 session 제거
    session.options[:skip] = true
    response.headers['Set-Cookie'] = 'rack.session=; path=/; expires=Thu, 01-Jan-1970 00:00:00 GMT'

    auth = request.env['omniauth.auth']
    user = from_omniauth(auth)
    @ret = {}

    if user && user.persisted?
      sign_in(:user, user, store: false)
      token = user.generate_auth_token!(auth_source)
      @ret = user.with_token(token)
    elsif user && user.errors.size > 0
      @ret = {
        error: {
          code: 'OAUTH_LOGIN_ERROR_EMAIL_INVALID',
          message: user.errors.full_messages.first,
          data: {
            oauth: {
              credentials: auth[:credentials],
              provider: auth[:provider],
              uid: auth[:uid],
              info: {
                name: auth[:info][:name],
                image: auth[:info][:image]
              }
            }
          }
        }
      }
    else
      @ret = {
        error: {
          code: 'OAUTH_LOGIN_ERROR',
          message: 'require provider & uid!!'
        }
      }
      @ret[:error][:data] = user if user
    end

    render :inline => "<script>(window.opener || window).oauthCallback(#{@ret.to_json}); if(window.opener) { window.close(); }</script>",
           :content_type => 'text/html'
  end

  def failure
    @ret = {
      error: {
        code: OmniAuth::Utils.camelize(failed_strategy.name),
        message: failure_message
      }
    }

    render :inline => "<script>(window.opener || window).oauthCallback(#{@ret.to_json}); if(window.opener) { window.close(); }</script>",
           :content_type => 'text/html'
  end

  alias_method :facebook, :all
  alias_method :twitter, :all

  private

  # omniauth callback 분석
  def from_omniauth(auth)
    if auth[:provider] && auth[:uid] # 인증정보가 있으면..
      oauth = OauthAuthentication.find_by_provider_and_uid(auth[:provider], auth[:uid])
      if oauth # 이미 가입되어 있다면 oauth 정보를 갱신함
        oauth.update_with_credential(auth[:credentials])
        oauth.save

        return oauth.user
      else # 가입 정보가 없음!
        if auth[:info][:email].present? # 이메일이 있으면 가입 또는 연동
          user = User.find_or_create_by(email: auth[:info][:email]) do |u|
            u.name = auth[:info][:name] || auth[:info][:email]
            u.password = Devise.friendly_token[0,20]
            u.skip_confirmation! if u.class.include? Devise::Models::Confirmable
            u.save
          end
          # 인증 대기 중이면 바로 인증시켜버림
          user.confirm! if user.class.include?(Devise::Models::Confirmable) && !user.confirmed?

          # oauth 정보 생성
          user.add_oauth_info(auth)

          return user
        else # 이메일이 없으면 추가정보를 입력받도록 함
          user = User.new
          user.errors.add(:email, "email required")

          return user
        end
      end
    end

    nil
  end
end