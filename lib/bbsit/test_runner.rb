require 'open3'
require 'childprocess'
module BBSit
  class TestRunner
    def initialize(command)
      @command = command
    end

    def run(filename)
      cmd = "#{@command} #{filename}"
      puts "Running \"#{cmd}\"...".blue
      process = ChildProcess.build(*cmd.split(' '))
      process.io.inherit!
      process.start

      begin
        process.poll_for_exit(10)
      rescue ChildProcess::TimeoutError
        process.stop # tries increasingly harsher methods to kill the process.
      end
    end
  end
end
