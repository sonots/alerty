require 'json'
require 'frontkick'
require 'shellwords'

class Alerty
  class Plugin
    class Exec
      def initialize(config)
        raise ConfigError.new("exec: command is not configured") unless config.command
        @command = config.command
      end

      def alert(record)
        Alerty.logger.info "exec: echo #{record.to_json.shellescape} | #{@command}"
        Frontkick.exec("echo #{record.to_json.shellescape} | #{@command}")
      end
    end
  end
end
