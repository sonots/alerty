class Alerty
  class PluginFactory
    class << self
      def plugins
        @plugins ||= Config.plugins.map {|config| new_plugin(config) }
      end

      def new_plugin(config)
        require "alerty/plugin/#{config.type}"
        class_name = "Alerty::Plugin::#{StringUtil.camelize(config.type)}"
        Object.const_get(class_name).new(config)
      end
    end
  end
end
