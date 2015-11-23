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
      record = {}
      with_retry do |retries|
        started_at = Time.now
        begin
          result = Frontkick.exec("#{@command} 2>&1", @opts)
        rescue Frontkick::Timeout => e
          record = {
            hostname:   @hostname,
            command:    @command,
            exitstatus: 1,
            output:     "`#{@command}` is timeout (#{@opts[:timeout]} sec)",
            started_at: started_at.to_f,
            duration:   @opts[:timeout],
            retries:    retries,
          }
        rescue Frontkick::Locked => e
          record = {
            hostname:   @hostname,
            command:    @command,
            exitstatus: 1,
            output:     "`#{@opts[:exclusive]}` is locked by another process",
            started_at: started_at.to_f,
            duration:   0,
            retries:    retries,
          }
        else
          record = {
            hostname:   @hostname,
            command:    @command,
            exitstatus: result.exitstatus,
            output:     result.stdout,
            started_at: started_at.to_f,
            duration:   result.duration,
            retries:    retries,
          }
        end
        Alerty.logger.info { "result: #{record.to_json}" }
        record
      end
      unless record[:exitstatus] == 0
        Config.plugins.each do |plugin|
          begin
            plugin.alert(record)
          rescue => e
            Alerty.logger.warn "#{e.class} #{e.message} #{e.backtrace.join("\n")}"
          end
        end
        exit record[:exitstatus]
      end
    end

    private

    def with_retry
      retries = 0
      while true
        record = yield(retries)
        break if record[:exitstatus] == 0
        break if retries >= Config.retry_limit
        retries += 1
        sleep Config.retry_interval
      end
    end

  end
end
