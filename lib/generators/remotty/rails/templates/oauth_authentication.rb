# OAuth Authentication 모델
#
class OauthAuthentication < ActiveRecord::Base
  # relation
  belongs_to :user

  # validation
  validates :user_id,  presence: true
  validates :provider, presence: true
  validates :uid,      presence: true

  # access_token, access_token_secret, expires 정보 업데이트
  def update_with_credential(credential)
    self.access_token = credential[:token]
    self.access_token_secret = credential[:secret] if credential[:secret]
    self.expires_at = Time.at(credential[:expires_at]).to_datetime if credential[:expires_at]
  end
end
