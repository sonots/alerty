require_relative 'alerty/string_util'
require_relative 'alerty/error'
require_relative 'alerty/config'
require_relative 'alerty/command'
require_relative 'alerty/logger'
require_relative 'alerty/cli'

class Alerty
  def self.logger
    @logger ||= Logger.new(Config.log_path, Config.log_shift_age, Config.log_shift_size).tap do |logger|
      logger.level = Config.log_level
    end
  end
end
