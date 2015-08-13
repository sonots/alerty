require 'open3'

class Alerty
  class Command
    def initialize(command:)
      @command = command
    end

    def run!
      stdout, stderr, status = Open3.capture3("#{@command} 2>&1", stdin_data: $stdin)
      if status.success?
        exit 0
      else
        Config.plugins.each do |plugin|
          begin
            plugin.alert(stdout)
          rescue => e
            Alerty.logger.warn "#{e.class} #{e.message} #{e.backtrace.join("\n")}"
          end
        end
        exit status.exitstatus
      end
    end
  end
end
