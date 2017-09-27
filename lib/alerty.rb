require_relative 'alerty/version'
require_relative 'alerty/error'
require_relative 'alerty/config'
require_relative 'alerty/command'
require_relative 'alerty/logger'
require_relative 'alerty/cli'
require_relative 'alerty/string_util'
require_relative 'alerty/plugin_factory'

class Alerty
  def self.logger
    @logger ||= Logger.new(Config.log_path, Config.log_shift_age, Config.log_shift_size).tap do |logger|
      logger.level = Config.log_level
    end
  end

  # @param [Hash] record
  # @option record [String] :hostname
  # @option record [String] :command
  # @option record [Integer] :exitstatus
  # @option record [String] :output
  # @option record [Float] :started_at unix timestamp
  # @option record [Float] :duration
  # @option record [Integer] :retries number of being retried
  def self.send(record)
    PluginFactory.plugins.each do |plugin|
      begin
        plugin.alert(record)
      rescue => e
        puts "#{e.class} #{e.message} #{e.backtrace.join("\n")}" if Config.debug?
        Alerty.logger.warn "#{e.class} #{e.message} #{e.backtrace.join("\n")}"
      end
    end
  end
end
