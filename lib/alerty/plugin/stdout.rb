require 'json'

class Alerty
  class Plugin
    class Stdout
      def initialize(config)
      end

      def alert(record)
        $stdout.puts record.to_json
      end
    end
  end
end
