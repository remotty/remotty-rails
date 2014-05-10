class CreateOauthAuthentications < ActiveRecord::Migration
  def change
    create_table :oauth_authentications do |t|
      t.references :user,     index: true
      t.string     :provider, index: true
      t.string     :uid,      index: true
      t.string     :access_token
      t.string     :access_token_secret
      t.datetime   :expires_at

      t.timestamps
    end
  end
end
