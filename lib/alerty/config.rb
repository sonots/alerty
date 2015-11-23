require 'yaml'
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
        @config ||= Hashie::Mash.new(YAML.load_file(config_path))
      end

      def log_path
        opts[:log_path] || config.log_path || 'STDOUT'
      end

      def log_level
        opts[:log_level] || config.log_level || 'warn'
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

      def retry_interval
        @random ||= Random.new
        randomness = retry_wait * 0.125
        retry_wait + @random.rand(-randomness .. randomness)
      end

      def plugins
        @plugins ||= config.fetch('plugins').map do |plugin|
          require "alerty/plugin/#{plugin.type}"
          class_name = "Alerty::Plugin::#{StringUtil.camelize(plugin.type)}" 
          Object.const_get(class_name).new(plugin)
        end
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
