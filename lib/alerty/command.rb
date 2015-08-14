require 'frontkick'
require 'socket'
require 'json'

class Alerty
  class Command
    def initialize(command:)
      @command = command
      @opts = { timeout: Config.timeout, exclusive: Config.lock_path }
      @hostname = Socket.gethostname
    end

    def run!
      started_at = Time.now
      result = Frontkick.exec("#{@command} 2>&1", @opts)
      record = {
        hostname:   @hostname,
        command:    @command,
        exitstatus: result.exitstatus,
        output:     result.stdout,
        started_at: started_at.to_f,
        duration:   result.duration,
      }
      Alerty.logger.info { "result: #{record.to_json}" }
      if result.success?
        exit 0
      else
        Config.plugins.each do |plugin|
          begin
            plugin.alert(record)
          rescue => e
            Alerty.logger.warn "#{e.class} #{e.message} #{e.backtrace.join("\n")}"
          end
        end
        exit result.exitstatus
      end
    end
  end
end
