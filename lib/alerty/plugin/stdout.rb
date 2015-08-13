class Alerty
  class Plugin
    class Stdout
      def initialize(config)
      end

      def alert(msg)
        $stdout.puts msg
      end
    end
  end
end
