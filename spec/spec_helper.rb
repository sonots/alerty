ENV['RACK_ENV'] = 'test'
Bundler.require :test

require 'pry'
require 'alerty'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
end
