# OAuth Authentication 모델생성 migration 파일
#
# ==== Columns
#
# * +user+ - User 모델
# * +provider+ - 인증 제공자
#   * facebook
#   * twitter
#   * google
#   * ...
# * +uid+ - 인증 ID
# * +access_token+ - access token
# * +access_token_secret+ - access token secret
#
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
