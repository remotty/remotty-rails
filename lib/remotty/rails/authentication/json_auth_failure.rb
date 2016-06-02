module Remotty::Rails
  module Authentication
    # return json Device error occur
    class JsonAuthFailure < ::Devise::FailureApp
      def http_auth_body
        return i18n_message unless request_format

        method = "to_#{request_format}"

        if method == "to_xml"
          {
            error: {
              code: "UNAUTHORIZED",
              message: i18n_message
            }
          }.to_xml(:root => "errors")
        elsif {}.respond_to?(method)
          {
            error: {
              code: "UNAUTHORIZED",
              message: i18n_message
            }
          }.send(method)
        else
          i18n_message
        end
      end

      def respond
        if http_auth?
          http_auth
        else
          redirect
        end
      end
    end
  end
end
