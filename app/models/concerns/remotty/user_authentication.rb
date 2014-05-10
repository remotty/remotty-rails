require 'httparty'

module Remotty::UserAuthentication
  extend ActiveSupport::Concern

  attr_accessor :auth_token

  def generate_auth_token!(source, source_info)
    token = nil

    loop do
      token = Devise.friendly_token
      break token unless self.auth_tokens.where(token: Digest::SHA512.hexdigest(token)).first
    end

    auth_token = AuthToken.create({user_id:self.id, token: Digest::SHA512.hexdigest(token)})
    auth_token.update_source(source, source_info)

    token
  end

  def with_token(token)
    self.auth_token = token;
    ::UserSerializer.new(self)
  end

  def set_oauth_avatar(auth)
    if auth.info.image
      if auth.provider == "facebook"
        url = "https://graph.facebook.com/#{auth.uid}/picture?type=large&access_token=#{auth.credentials.token}&redirect=0"
        data = HTTParty.get(url).parsed_response
        return unless data

        json = JSON.parse(data)
        return unless json["data"]["url"]

        io = open(URI.parse(json["data"]["url"]))
        def io.original_filename; 'profile.jpg'; end # dirty T_T
        self.avatar = io
        self.save
      elsif auth['provider'] == "twitter"
        io = open(auth['info']['image'])
        def io.original_filename; 'profile.png'; end # dirty T_T
        self.avatar = io
        self.save
      end
    end
  end
end


