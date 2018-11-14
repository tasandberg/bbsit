module BBSit
  class TestRunner
    def initialize(command)
      @command = command
    end

    def self.run(filename, command)
      cmd = "#{command} #{filename}"
      log "Running \"#{cmd}\"..."
      output_arr = []

      Open3.popen3(cmd) do |_stdout, stderr, _status, _thread|
        while (line = stderr.gets)
          output_arr << line
          puts line
        end
      end

      output_arr
    end
  end
end