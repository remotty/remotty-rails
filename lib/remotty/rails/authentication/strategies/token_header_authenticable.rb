require 'devise'

# Request Header의 auth token을 이용한 authentication
# X-Auth-Email : e-mail
# X-Auth-Token : auth token
# X-Auth-Device : source (web(default)/ios/android/...)
# X-Auth-Device-Info : source info (ip(default)/...)

module Remotty
  module Rails
    module Authentication
      module Strategies
        class TokenHeaderAuthenticable < ::Devise::Strategies::Base
          def store?
            super && !mapping.to.skip_session_storage.include?(:token_header_auth)
          end

          def valid?
            header_email && (ENV["RAILS_ENV"] == "development" || header_token)
          end

          def authenticate!
            resource_scope = mapping.to
            resource = resource_scope.find_by_email(header_email)

            if resource
              if ENV["RAILS_ENV"] == "development"# && header_token.nil?
                success!(resource)
              else
                auth_token = resource.auth_tokens.where("token = ? and updated_at > ?",
                                                        Digest::SHA512.hexdigest(header_token), mapping.to.remember_for.ago).first
                if auth_token
                  auth_token.update_source source, source_info

                  success!(resource)
                else
                  fail!
                end
              end
            else
              fail!
            end
          end

        private

          def source
            request.headers["X-Auth-Device"] || 'web'
          end

          def source_info
            request.headers["X-Auth-Device-Info"] || request.remote_ip
          end

          def header_email
            request.headers["X-Auth-Email"]
          end

          def header_token
            request.headers["X-Auth-Token"]
          end

        end
      end
    end
  end
end
