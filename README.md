# Remotty::Rails

Remotty에서 사용하는 rails관련 base package입니다.
AngularJS + Rails API를 사용할 때 기본적인 셋팅을 도와주어 빠른 초기 셋팅을 가능하게 합니다.

## library

일반적으로 사용되는 유명 라이브러리들과 remotty에서 자체적으로 만든 라이브러리를 함께 사용합니다.

* rails
  * `rails-api` (https://github.com/rails-api/rails-api)
  * `active_model_serializers` (https://github.com/rails-api/active_model_serializers)
  * `paperclip` (https://github.com/thoughtbot/paperclip)
* authentication
  * `devise` (https://github.com/plataformatec/devise)
  * `token_header_authenticable` (by remotty)
  * `json_auth_failure` (by remotty)
  * `custom_user_controllers` (by remotty)
  * `user_authentication` (by remotty)
  * `user_serializer` (by remotty)
* controller helper
  * `remotty::application_controller` (by remotty)

## by remotty

### token_header_authenticable

header에 email과 token을 전달하여 인증을 처리함

* X-Auth-Email : e-mail
* X-Auth-Token : auth token
* X-Auth-Device : source (web(default)/ios/android/...)
* X-Auth-Device-Info : source info (ip(default)/...)

### json_auth_failure

devise 에러처리

```
{
  error: {
    code: "UNAUTHORIZED",
    message: message
  }
}
```

### Remotty::ApplicationController

render_error

```
render json: {
  error: {
    code: code,
    message: message
  }
}, :status => status
```

### Remotty::UserAuthentication

user model helper

### Remotty::UserSerializer

add token (virtual attribute)

## Installation

Create Rails API Project

    $ gem install rails -v 4.0.4 --no-ri --no-rdoc
    $ rails-api new {{project}} --skip-test-unit --skip-sprockets

Add this line to your application's Gemfile:

    # Remotty Rails Package
    gem 'remotty-rails'
    gem 'rack-cors', :require => 'rack/cors'
    gem 'active_model_serializers'

    # Authentication
    gem 'devise'
    gem 'omniauth-facebook'
    gem 'omniauth-twitter'

    # File upload
    gem 'paperclip'
    gem 'rmagick', require: false
    gem 'fog'

    group :development do
      gem 'thin'
      gem 'annotate'
      gem 'better_errors'
      gem 'binding_of_caller'
      gem 'letter_opener'
    end

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install remotty-rails


Model Migration

    $ rails generate devise:install
    $ rails generate devise User
    $ rails generate remotty:rails:install
    $ rails generate serializer user

## Usage

### initializers/devise.rb

* skip session storage
```
config.skip_session_storage = [:http_auth, :token_header_auth, :params_auth]
```

* scoped view

```
config.scoped_views = true
```

* add strategies & failure_app

```
config.warden do |manager|
  manager.failure_app = Remotty::Rails::Authentication::JsonAuthFailure
  manager.strategies.add :token_header_authenticable, Remotty::Rails::Authentication::Strategies::TokenHeaderAuthenticable
  manager.default_strategies(:scope => :user).unshift :token_header_authenticable
end
```

* 토큰 유효기간

```
config.remember_for = 2.weeks
```

### user.rb

* user model

```
class User < ActiveRecord::Base
  include Remotty::UserAuthentication
  include Remotty::Attachment

  devise :database_authenticatable, :registerable, :confirmable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :auth_tokens, dependent: :destroy
  has_many :oauth_authentications, dependent: :destroy

  validates :name, presence: true

  has_attached_file :avatar, :styles => { :original => "512x512#", :small => "200x200#", :thumb => "64x64#" }, :default_url => ''
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  remotty_attachmenty :avatar

end
```

### user_serializer.rb

* user serializer

```
class UserSerializer < Remotty::UserSerializer
end
```

### development.rb

```
config.action_mailer.delivery_method = :letter_opener
```

### routes.rb

```
  scope :api do
    scope :v1 do
      devise_for :users,
                 :path => 'session',
                 :path_names => {
                   sign_in: 'login',
                   sign_out: 'logout'
                 },
                 :controllers => { sessions:           'remotty/users/sessions',
                                   registrations:      'remotty/users/registrations',
                                   confirmations:      'remotty/users/confirmations',
                                   omniauth_callbacks: 'remotty/users/omniauth_callbacks'}
    end
  end
```

### Application Controller Helper

* application_controller 상속

```
class ApplicationController < Remotty::ApplicationController
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :current_password, :avatar) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :avatar, :password, :password_confirmation, :current_password) }
    # :name, :avatar, :current_password
  end
end
```

### paperclip

* initialzers/paperclip.rb

```
Paperclip::Attachment.default_options.update({ :hash_secret => 'xxxxxxx' }) # SecureRandom.base64(128)
```

### custom mail view
  * views/devise/mailer/confirmation_instructions.html.erb
  * views/devise/mailer/reset_password_instructions.html.erb

## Contributing

1. Fork it ( https://github.com/[my-github-username]/remotty-rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
