require 'open3'

module BBSit
  class TestRunner
    def initialize(command)
      @command = command
    end

    def run(filename)
      cmd = "#{@command} #{filename}"
      puts "Running \"#{cmd}\"...".blue
      Open3.popen3(cmd) do |_stdout, stderr, _status, _thread|
        while (line = stderr.gets)
          puts line
        end
      end
    end
  end
end