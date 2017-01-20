require 'yaml'
require 'erb'
require 'hashie/mash'

class Alerty
  class Config
    class << self
      attr_reader :opts

      def configure(opts)
        @opts = opts
      end

      def config_path
        @config_path ||= opts[:config_path] || ENV['ALERTY_CONFIG_PATH'] || '/etc/alerty/alerty.yml'
      end

      def config
        return @config if @config
        if dotenv?
          require 'dotenv'
          Dotenv.load
        end
        content = File.read(config_path)
        erb = ERB.new(content, nil, '-')
        erb_content = erb.result
        if debug?
          puts '=== Erb evaluated config ==='
          puts erb_content
        end
        yaml = YAML.load(erb_content)
        @config = Hashie::Mash.new(yaml)
        if debug?
          puts '=== Recognized config ==='
          puts({
            'log_path' => log_path,
            'log_level' => log_level,
            'log_shift_age' => log_shift_age,
            'log_shift_size' => log_shift_size,
            'timeout' => timeout,
            'lock_path' => lock_path,
            'retry_limit' => retry_limit,
            'retry_wait' => retry_wait,
            'plugin' => yaml['plugins'],
          }.to_yaml)
        end
        @config
      end

      def log_path
        opts[:log_path] || config.log_path || 'STDOUT'
      end

      def log_level
        opts[:log_level] || config.log_level || 'warn'
      end

      def log_shift_age
        # config.shift_age is for old version compatibility
        opts[:log_shift_age] || config.shift_age || config.log_shift_age || 0
      end

      def log_shift_size
        # config.log_shift_age is for old version compatibility
        opts[:log_shift_size] || config.shift_size || config.log_shift_size || 1048576
      end

      def timeout
        opts[:timeout] || config.timeout
      end

      def lock_path
        opts[:lock_path] || config.lock_path
      end

      def retry_limit
        opts[:retry_limit] || config.retry_limit || 0
      end

      def retry_wait
        opts[:retry_wait] || config.retry_wait || 1.0
      end

      def debug?
        !!opts[:debug]
      end

      def dotenv?
        !!opts[:dotenv]
      end

      def retry_interval
        @random ||= Random.new
        randomness = retry_wait * 0.125
        retry_wait + @random.rand(-randomness .. randomness)
      end

      def plugins
        @plugins ||= config.fetch('plugins')
      end

      # for debug
      def reset
        @config_path = nil
        @config = nil
        @plugins = nil
      end
    end
  end
end
