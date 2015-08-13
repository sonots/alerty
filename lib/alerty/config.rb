require 'yaml'
require 'hashie/mash'

class Alerty
  class Config
    class << self
      def configure(config_path: )
        @config_path = config_path
      end

      def config_path
        @config_path ||= ENV['ALERTY_CONFIG_PATH'] || '/etc/sysconfig/alerty'
      end

      def config
        @config ||= Hashie::Mash.new(YAML.load_file(config_path))
      end

      def log_path
        config.log_path || 'STDOUT'
      end

      def log_level
        config.log_level || 'warn'
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
