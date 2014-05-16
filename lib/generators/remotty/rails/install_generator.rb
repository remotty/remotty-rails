require 'rails/generators'
require 'rails/generators/migration'

module Remotty::Rails
  module Generators
    # 마이그레이션 생성 및 각종 클래스&설정 추가 및 변경
    #
    # ==== migration
    # * +add_column_to_users.rb+ - user
    # * +create_auth_tokens.rb+ - auth token
    # * +create_oauth_authentications.rb+ - oauth authentication
    #
    # ==== model
    # * +auth_token.rb+ - auth token
    # * +oauth_authentication.rb+ - oauth_authentication
    # * +user.rb+ - user model에 base include
    #
    # ==== configuration
    # * +paperclip_hash.rb+ - paperclip hash
    #
    # ==== serializer
    # * +user_serializer.rb+ - user model serializer
    #
    # ==== controller
    # * +application_controller.rb+ - application controller에 base include
    #
    class InstallGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration

      desc "Creates a Remotty Rails model initializer and copy files to your application."

      source_root File.expand_path("../templates", __FILE__)

      # migration number 생성용 변수
      @migration_index = 0

      # migration number는 현재날짜시간 + index(1,2,...) 형식으로 생성함
      def self.next_migration_number(path)
        @migration_index += 1
        (Time.now.utc.strftime("%Y%m%d%H%M%S").to_i + @migration_index).to_s
      end

      # add & update files
      def copy_purple_attachment
        template 'auth_token.rb', 'app/models/auth_token.rb'
        template 'oauth_authentication.rb', 'app/models/oauth_authentication.rb'
        template 'user_serializer.rb', 'app/serializers/user_serializer.rb'
        template 'paperclip_hash.rb', 'config/initializers/paperclip_hash.rb'
        append_to_file 'config/initializers/paperclip_hash.rb' do
          secret = SecureRandom.hex(40)
          "Paperclip::Attachment.default_options.update({ :hash_secret => '#{secret}' })"
        end
        inject_into_class 'app/controllers/application_controller.rb', ApplicationController do
          "  include Remotty::BaseApplicationController\n"
        end
        inject_into_class 'app/models/user.rb', User do
          "  include Remotty::BaseUser\n"
        end
        gsub_file 'app/models/user.rb', 'registerable', 'registerable, :omniauthable'

        migration_template 'add_column_to_users.rb',          'db/migrate/add_column_to_users.rb'
        migration_template 'create_auth_tokens.rb',           'db/migrate/create_auth_tokens.rb'
        migration_template 'create_oauth_authentications.rb', 'db/migrate/create_oauth_authentications.rb'
      end

    end
  end
end
