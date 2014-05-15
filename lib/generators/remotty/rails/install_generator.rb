require 'rails/generators'
require 'rails/generators/migration'

module Remotty
  module Rails
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        include ::Rails::Generators::Migration

        desc "Creates a Remotty Rails model initializer and copy files to your application."

        source_root File.expand_path("../templates", __FILE__)

        @migration_index = 0

        def self.next_migration_number(path)
          @migration_index += 1
          (Time.now.utc.strftime("%Y%m%d%H%M%S").to_i + @migration_index).to_s
        end
        def copy_purple_attachment
          template 'auth_token.rb', 'app/models/auth_token.rb'
          template 'oauth_authentication.rb', 'app/models/oauth_authentication.rb'
          template 'paperclip_hash.rb', 'config/initializers/paperclip_hash.rb'
          append_to_file 'config/initializers/paperclip_hash.rb' do
            secret = SecureRandom.hex(40)
            "Paperclip::Attachment.default_options.update({ :hash_secret => '#{secret}' })"
          end
          migration_template 'add_column_to_users.rb',          'db/migrate/add_column_to_users.rb'
          migration_template 'create_auth_tokens.rb',           'db/migrate/create_auth_tokens.rb'
          migration_template 'create_oauth_authentications.rb', 'db/migrate/create_oauth_authentications.rb'
        end

      end
    end
  end
end
