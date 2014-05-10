module Remotty::AuthTokenSource
  extend ActiveSupport::Concern

  def update_source(source, source_info)
    if self.source != source || self.source_info != source_info
      self.update(source: source, source_info: source_info)
    else
      self.touch
    end
  end

end