class Remotty::UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :use_password, :avatar, :auth_token

  def avatar
    {
      original:object.avatar.url,
      small:object.avatar.url(:small),
      thumb:object.avatar.url(:thumb)
    }
  end

  def include_auth_token?
    object.auth_token
  end
end


