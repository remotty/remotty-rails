# base user controller
#
module Remotty::Users::BaseController
  extend ActiveSupport::Concern

  protected

  # auth_source 정보 추출 (앱 확장성 고려)
  def auth_source
    {
      source: request.headers['X-Auth-Device'] || 'web',
      info: request.headers['X-Auth-Device-Info'] || request.remote_ip
    }
  end

end
