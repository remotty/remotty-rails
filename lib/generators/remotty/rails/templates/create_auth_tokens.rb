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
