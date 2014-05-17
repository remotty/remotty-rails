require 'httparty'

module Remotty::BaseUser
  extend ActiveSupport::Concern

  included do
    has_many :auth_tokens, dependent: :destroy
    has_many :oauth_authentications, dependent: :destroy

    validates :name, presence: true

    has_attached_file :avatar, :styles => { :original => "512x512#", :small => "200x200#", :thumb => "64x64#" }
    validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  end

  attr_accessor :auth_token

  def generate_auth_token!(auth_source)
    token = nil

    loop do
      token = Devise.friendly_token
      break token unless self.auth_tokens.where(token: Digest::SHA512.hexdigest(token)).first
    end

    auth_token = AuthToken.create({user_id:self.id, token: Digest::SHA512.hexdigest(token)})
    auth_token.update_source(auth_source[:source], auth_source[:info])

    token
  end

  def with_token(token)
    self.auth_token = token;
    ::UserSerializer.new(self)
  end

  # oauth authentication 추가
  #
  # * +auth+ : auth 정보
  #   * provider, uid, info(name, image), credentials(token, secret, expires_at)
  #
  def add_oauth_info(auth)
    oauth = OauthAuthentication.find_or_create_by(provider: auth[:provider], uid: auth[:uid])
    if oauth
      oauth.update_with_credential(auth[:credentials])
      oauth.user = self
      oauth.save
    end

    if auth[:info][:image]
      self.avatar_remote_url = auth[:info][:image]
      self.save
    end
  end

  # remote url attachment helper
  #
  def avatar_remote_url=(url)
    avatar_url = process_uri(url)
    self.avatar = URI.parse(avatar_url)
    # Assuming url_value is http://example.com/photos/face.png
    # avatar_file_name == "face.png"
    # avatar_content_type == "image/png"
    @avatar_remote_url = avatar_url
  end

  private

  # fix uri redirection (http -> https)
  def process_uri(uri)
    ret = uri

    require 'open-uri'
    require 'open_uri_redirections'
    begin
      open(uri, :allow_redirections => :safe) do |r|
        ret = r.base_uri.to_s
      end
    end

    ret
  end
end


