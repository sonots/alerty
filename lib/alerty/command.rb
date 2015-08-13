require 'frontkick'

class Alerty
  class Command
    def initialize(command:)
      @command = command
      @opts = { timeout: Config.timeout, exclusive: Config.lock_path }
    end

    def run!
      result = Frontkick.exec("#{@command} 2>&1", @opts)
      if result.success?
        exit 0
      else
        Config.plugins.each do |plugin|
          begin
            plugin.alert(result.stdout)
          rescue => e
            Alerty.logger.warn "#{e.class} #{e.message} #{e.backtrace.join("\n")}"
          end
        end
        exit result.exitstatus
      end
    end
  end
end
