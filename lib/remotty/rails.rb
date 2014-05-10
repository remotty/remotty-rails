require 'remotty/rails/version'

module Remotty
  module Rails
    require 'remotty/rails/engine' if defined?(Rails)
    require 'remotty/rails/authentication'
  end
end
