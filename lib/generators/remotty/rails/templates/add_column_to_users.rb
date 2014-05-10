class AddColumnToUsers < ActiveRecord::Migration
  def self.up
    # avatar
    add_attachment :users, :avatar

    # name
    add_column     :users, :name, :string, limit: 50

    # use_password
    add_column     :users, :use_password, :boolean

    # confirmation
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at,       :datetime
    add_column :users, :confirmation_sent_at , :datetime
    add_column :users, :unconfirmed_email, :string

    add_index  :users, :confirmation_token, :unique => true
  end

  def self.down
    remove_attachment :users, :avatar
    remove_column     :users, :name, :string, limit: 50
    remove_column     :users, :use_password, :boolean

    remove_index  :users, :confirmation_token

    remove_column :users, :unconfirmed_email
    remove_column :users, :confirmation_sent_at
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_token
  end
end


