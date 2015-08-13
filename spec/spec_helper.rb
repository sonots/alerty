ENV['RACK_ENV'] = 'test'
Bundler.require :test

require 'pry'
require 'alerty'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ROOT = File.dirname(File.dirname(__FILE__))
def capture_stdout
  out = StringIO.new
  $stdout = out
  yield
  return out.string
ensure
  $stdout = STDOUT
end

RSpec.configure do |config|
end
