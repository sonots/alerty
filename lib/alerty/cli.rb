require 'optparse'
require_relative '../alerty'

class Alerty
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

    opts = {
      config: '/etc/sysconfig/alerty',
    }

    op.on('-c', '--config CONFIG_PATH', "config file path (default: #{opts[:config]})") {|v|
      opts[:config] = v
    }

    op.parse!(argv)

    opts[:command] = argv.join(' ')

    if opts[:command].empty?
      usage "No command is given"
    end

    opts
  end

  def run
    begin
      opts = parse_options
    rescue OptionParser::InvalidOption => e
      usage e.message
    end

    Config.configure(config_path: opts[:config]) if opts[:config]
    Config.plugins # load plugins in early stage
    Command.new(command: opts[:command]).run!
  end
end
