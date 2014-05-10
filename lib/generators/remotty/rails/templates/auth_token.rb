class AuthToken < ActiveRecord::Base
  include Remotty::AuthTokenSource

  # relation
  belongs_to :user

  # validation
  validates :user_id,     presence: true
  validates :token,       presence: true
  validates :source,      presence: true
  validates :source_info, presence: true
end
