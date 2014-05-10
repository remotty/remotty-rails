# Remotty::Rails

Remotty에서 사용하는 rails관련 base package입니다.

## 개발환경

* rails
  * `rails-api` (https://github.com/rails-api/rails-api)
* authentication
  * `devise` (https://github.com/plataformatec/devise)
  * `token_header_authenticable` (by remotty)

## Installation

Add this line to your application's Gemfile:

    gem 'remotty-rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install remotty-rails

## Usage

### authentication

* add strategies

```
config.warden do |manager|
  manager.strategies.add :token_header_authenticable, Remotty::Rails::Strategies::TokenHeaderAuthenticable
  manager.default_strategies(:scope => :user).unshift :token_header_authenticable
end
```

* 토큰 유효기간

```
config.remember_for = 2.weeks
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/remotty-rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
