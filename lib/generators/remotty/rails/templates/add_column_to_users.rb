# User 모델에 이름, 프로필 사진, 메일 인증 관련 컬럼을 추가 migration 파일
#
# ==== Columns
#
# * +avatar+ - Paperclip style 사용자 프로필 이미지
# * +name+ - 사용자 이름
# * +use_password+ - 사용자 패스워드 (일반 회원가입시 +true+, oauth 로그인시 +false+)
# * +avatar+ - Paperclip style 사용자 프로필 이미지
# * +confirmation_token+ - Device's confirmation column
# * +confirmed_at+ - Device's confirmation column
# * +confirmation_sent_at+ - Device's confirmation column
# * +unconfirmed_email+ - Device's confirmation column
#
class AddColumnToUsers < ActiveRecord::Migration
  def self.up
    add_attachment :users, :avatar
    add_column     :users, :name, :string, limit: 50
    add_column     :users, :use_password, :boolean

    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at,       :datetime
    add_column :users, :confirmation_sent_at , :datetime
    add_column :users, :unconfirmed_email, :string

    add_index  :users, :confirmation_token, :unique => true
  end

  def self.down
    remove_attachment :users, :avatar
    remove_column     :users, :name
    remove_column     :users, :use_password

    remove_index  :users, :confirmation_token

    remove_column :users, :unconfirmed_email
    remove_column :users, :confirmation_sent_at
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_token
  end
end


