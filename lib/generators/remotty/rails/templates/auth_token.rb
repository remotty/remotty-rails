# Auth Token 모델
#
class AuthToken < ActiveRecord::Base
  # relation
  belongs_to :user

  # validation
  validates :user_id,     presence: true
  validates :token,       presence: true
  validates :source,      presence: true
  validates :source_info, presence: true

  # source 정보 업데이트
  # 보통 ip가 변경될 경우가 많을듯 하고 변하지 않더라도 최종 갱신시간을 변경함
  def update_source(source, source_info)
    if self.source != source || self.source_info != source_info
      self.update(source: source, source_info: source_info)
    else
      self.touch
    end
  end
end
