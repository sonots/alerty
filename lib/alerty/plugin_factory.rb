require_relative 'string_util'

class Alerty
  class PluginFactory
    def self.create(config)
      require "alerty/plugin/#{config.type}"
      class_name = "Alerty::Plugin::#{StringUtil.camelize(config.type)}"
      Object.const_get(class_name).new(config)
    end
  end
end
