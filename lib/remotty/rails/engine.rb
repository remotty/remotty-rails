require 'rails'
require 'rack/cors'
require 'active_model/serializer'
require 'active_model/array_serializer'

module Remotty
  module Rails
    class Engine < ::Rails::Engine
      initializer '0.remotty.rails.configuration' do |app|
        # active serializer
        ActiveModel::Serializer.root = false
        ActiveModel::ArraySerializer.root = false

        # wrap parameters
        ActiveSupport.on_load(:action_controller) do
          include ActionController::ParamsWrapper
          wrap_parameters format: [:json] if respond_to?(:wrap_parameters)
        end

        # paperclip
        Paperclip::Attachment.default_options.update({
                                                       :url => '/system/:class/:attachment/:id_partition/:style/:hash.:extension',
                                                       :default_url => ''
                                                     })

        # Devise
        Devise.setup do |config|
          config.skip_session_storage = [:http_auth, :token_header_auth, :params_auth]
          config.scoped_views = true
          config.warden do |manager|
            manager.failure_app = Remotty::Rails::Authentication::JsonAuthFailure
            manager.strategies.add :token_header_authenticable, Remotty::Rails::Authentication::Strategies::TokenHeaderAuthenticable
            manager.default_strategies(:scope => :user).unshift :token_header_authenticable
          end
        end

        # CORS
        ::Rails.application.config.middleware.use Rack::Cors do
          allow do
            origins "*"
            resource "*", :headers => :any, :methods => [:get, :post, :delete, :put, :patch, :options]
          end
        end

        # session for oauth/devise (no cookie)
        ::Rails.application.config.middleware.use Rack::Session::Pool
        ::Rails.application.config.middleware.use ActionDispatch::Session::CookieStore, :cookie_only => false, :defer => true
        ::Rails.application.config.middleware.use ActionDispatch::Flash
      end

    end
  end
end
