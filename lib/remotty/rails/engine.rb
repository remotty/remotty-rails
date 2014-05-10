require 'rails'
require 'rack/cors'

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
