class OauthAuthentication < ActiveRecord::Base
  # relation
  belongs_to :user

  # validation
  validates :user_id,  presence: true
  validates :provider, presence: true
  validates :uid,      presence: true

  def set_oauth_info(auth)
    self.access_token = auth.credentials.token
    self.access_token_secret = auth.credentials.secret if auth.credentials.secret
    self.expires_at = Time.at(auth.credentials.expires_at).to_datetime if auth.credentials.expires_at
  end
end
