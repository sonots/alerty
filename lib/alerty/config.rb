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
        @config_path ||= opts[:config_path] || ENV['ALERTY_CONFIG_PATH'] || '/etc/sysconfig/alerty'
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

      def plugins
        @plugins ||= config.fetch('plugins').map do |plugin|
          require "alerty/plugin/#{plugin.type}"
          class_name = "Alerty::Plugin::#{StringUtil.camelize(plugin.type)}" 
          Object.const_get(class_name).new(plugin)
        end
      end
    end
  end
end
