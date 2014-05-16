# Auth Token 모델생성 migration 파일
#
# ==== Columns
#
# * +user+ - User 모델
# * +token+ - 인증 토큰
#   * token은 Devise.friendly_token로 생성하고 Digest::SHA512.hexdigest로 암호화하여 저장
# * +source+ - 토큰 생성자
#   * web(default)
#   * ios
#   * android
#   * ...
# * +source_info+ - 토큰 생성자 정보
#   * ip(default)
#   * ...
#
class CreateAuthTokens < ActiveRecord::Migration
  def change
    create_table :auth_tokens do |t|
      t.references :user, index: true
      t.string     :token
      t.string     :source
      t.string     :source_info

      t.timestamps
    end
  end
end
