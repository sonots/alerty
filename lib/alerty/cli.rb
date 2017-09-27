require 'optparse'
require 'socket'
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
      op.on('-c', '--config CONFIG_FILE', "config file path (default: /etc/alerty/alerty.yml)") {|v|
        opts[:config_path] = v
      }
      op.on('--log LOG_FILE', "log file path (default: STDOUT)") {|v|
        opts[:log_path] = v
      }
      op.on('-l', '--log-level LOG_LEVEL', "log level (default: warn)") {|v|
        opts[:log_level] = v
      }
      op.on('--log-shift-age SHIFT_AGE', "Number of old log files to keep (default: 0 which means no log rotation)") {|v|
        opts[:log_shift_age] = Integer(v)
      }
      op.on('--log-shift-size SHIFT_SIZE', "Maximum logfile size in bytes (default: 1048576)") {|v|
        opts[:log_shift_age] = Integer(v)
      }
      op.on('-t', '--timeout SECONDS', "timeout the command (default: no timeout)") {|v|
        opts[:timeout] = v.to_f
      }
      op.on('--lock LOCK_FILE', "exclusive lock file to prevent running a command duplicatedly (default: no lock)") {|v|
        opts[:lock_path] = v
      }
      op.on('--retry-limit NUMBER', "number of retries (default: 0)") {|v|
        opts[:retry_limit] = v.to_i
      }
      op.on('--retry-wait SECONDS', "retry interval = retry wait +/- 12.5% randomness (default: 1.0)") {|v|
        opts[:retry_wait] = v.to_f
      }
      op.on('--dotenv', "Load environment variables from .env file with dotenv") {|v|
        opts[:dotenv] = true
      }
      op.on('-d', '--debug', "debug mode") {|v|
        opts[:debug] = true
      }
      op.on('-v', '--version', "print version") {|v|
        puts Alerty::VERSION
        exit 0
      }

      op.parse!(argv)
      opts[:command] = argv.join(' ')

      opts
    end

    def run
      begin
        opts = parse_options
      rescue OptionParser::InvalidOption => e
        usage e.message
      end
  
      Config.configure(opts)
      PluginFactory.plugins # load plugins in early stage

      if opts[:command]
        command = Command.new(command: opts[:command])
        record = command.run
        unless record[:exitstatus] == 0
          Alerty.send(record)
          exit record[:exitstatus]
        end
      else
        record = {hostname: Socket.gethostname, output: $stdin.read}
        Alerty.send(record)
      end
    end
  end
end
