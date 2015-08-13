require 'optparse'
require_relative '../alerty'

class Alerty
  class CLI
    def parse_options(argv = ARGV)
      op = OptionParser.new
      op.banner += ' -- command'

      (class<<self;self;end).module_eval do
        define_method(:usage) do |msg|
          puts op.to_s
          puts "error: #{msg}" if msg
          exit 1
        end
      end

      opts = {}
      op.on('-c', '--config CONFIG_FILE', "config file path (default: /etc/sysconfig/alerty)") {|v|
        opts[:config_path] = v
      }
      op.on('--log LOG_FILE', "log file path (default: STDOUT)") {|v|
        opts[:log_path] = v
      }
      op.on('--log-level LOG_LEVEL', "log level (default: warn)") {|v|
        opts[:log_level] = v
      }
      op.on('-t', '--timeout SECONDS', "timeout the command (default: no timeout)") {|v|
        opts[:timeout] = v.to_i
      }
      op.on('-l', '--lock LOCK_FILE', "exclusive lock file to prevent running a command duplicatedly (default: no lock)") {|v|
        opts[:lock_path] = v
      }

      op.parse!(argv)
      opts[:command] = argv.join(' ')

      if opts[:command].empty?
        raise OptionParser::InvalidOption.new("No command is given")
      end

      opts
    end

    def run
      begin
        opts = parse_options
      rescue OptionParser::InvalidOption => e
        usage e.message
      end
  
      Config.configure(opts)
      Config.plugins # load plugins in early stage
      command = Command.new(command: opts[:command])
      command.run!
    end
  end
end
