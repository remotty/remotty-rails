# remotty-rails

AngularJS + Rails API를 사용할 때 기본적인 셋팅을 도와주어 빠른 초기 셋팅을 가능하게 합니다.

## Description

### 적용사항

* header의 token을 이용한 인증처리
  * auth_token model 추가
* facebook/twitter oauth login
  * oauth_authentication model 추가
* join
  * email
  * oauth (facebook/twitter)
  * email이 없는 경우도 처리
* custom devise controller
  * full customizing
  * json response
  * sessions controller
  * registrations controller
  * confirmations controller
  * passwords controller
  * omniauth_callbacks controller
* user model
  * use avatar for profile image
* use paperclip for attachment
* use serializer for json response
* CORS
* no cookie/no session

### Token Based Header Authenticable

header에 email과 token을 전달하여 인증을 처리함

* X-Auth-Email : e-mail
* X-Auth-Token : auth token
* X-Auth-Device : source (web(default)/ios/android/...)
* X-Auth-Device-Info : source info (ip(default)/...)

### JSON format

* disable root globally
* failure default syntax

```json
{
  "error":{
    "code":"ERROR_CODE",
    "message":"error message"
  }
}
```

### Controller Helper

* render_error helper

```ruby
def render_error(code = 'ERROR', message = '', status = 400)
  render json: {
    error: {
      code: code,
      message: message
    }
  }, :status => status
end
```


## Library

remotty-rails에서 사용중인 라이브러리 입니다.

* `rails-api`
  * Rails for API only application (https://github.com/rails-api/rails-api)
* `active_model_serializers`
  * JSON serialization of objects (https://github.com/rails-api/active_model_serializers)
* `paperclip`+`rmagick`+`fog`+`httparty`
  * Easy file attachment management (https://github.com/thoughtbot/paperclip)
* `devise`
  * Flexible authentication solution (https://github.com/plataformatec/devise)


## Installation

* Create Rails API Project

```sh
$ gem install rails -v 4.0.5 --no-ri --no-rdoc
$ rails-api new {{project}} --skip-test-unit --skip-sprockets
```

* Add this line to your application's Gemfile:

```ruby
gem 'remotty-rails'
gem 'devise'
gem 'paperclip'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
```

* And then execute:

```sh
$ bundle
```

* Model Migration

```sh
$ rails generate devise:install
$ rails generate devise User
$ rails generate remotty:rails:install
$ rake db:migrate
```

* `config/routes.rb` update

```ruby
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
                                 passwords:          'remotty/users/passwords',
                                 omniauth_callbacks: 'remotty/users/omniauth_callbacks'}
  end
end
```

## Recommend Setting

### 유용한 Gemfile

`Gemfile` update

```ruby
group :development do
  gem 'thin'
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener'
end
```

### sendmail test

`development.rb` update

```ruby
config.action_mailer.delivery_method = :letter_opener
```

### custom mail view


`views/devise/mailer/confirmation_instructions.html.erb` create
`views/devise/mailer/reset_password_instructions.html.erb` create


### token 유효기간 변경

`initializers/devise.rb` update

```ruby
config.remember_for = 2.weeks
```

### omniauth setting

`devise.rb` update

```ruby
config.omniauth :facebook,
                Settings.omniauth.facebook.app_id,
                Settings.omniauth.facebook.app_secret,
                {
                  scope: 'email',
                  image_size: 'large',
                  provider_ignores_state: true
                }
config.omniauth :twitter,  
                Settings.omniauth.twitter.consumer_key,
                Settings.omniauth.twitter.consumer_secret, {
                :image_size => 'original',
                :authorize_params => {
                  :force_login => true
                },
                :setup => lambda do |env|
                  req = Rack::Request.new(env)
                  req.session.options[:cookie_only] = true
                  req.session.options[:defer] = false
                end
```

### devise parameter sanitizer  

user model에 column 추가시 `application_controller.rb` 파일에 추가함

```ruby
class ApplicationController < ActionController::API

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :current_password, :avatar) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :avatar, :password, :password_confirmation, :current_password) }
  end
end
```

## Contributing

1. Fork it ( https://github.com/remotty/remotty-rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
