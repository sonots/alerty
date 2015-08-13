require_relative 'alerty/string_util'
require_relative 'alerty/error'
require_relative 'alerty/config'
require_relative 'alerty/command'
require_relative 'alerty/logger'

class Alerty
  def self.logger
    @logger ||= Logger.new(Config.log_path).tap do |logger|
      logger.level = Config.log_level
    end
  end
end
