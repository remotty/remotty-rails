module Remotty
  module Rails
    module Authentication
      require 'remotty/rails/authentication/strategies/token_header_authenticable'
      autoload :JsonAuthFailure, 'remotty/rails/authentication/json_auth_failure'
    end
  end
end
