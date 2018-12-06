require 'open3'
require 'terminal-notifier'

module BBSit
  # BBSitter watches for changes in code and looks for corresponding tests to run.
  class BBSitter
    def initialize(framework: 'rspec', watch_dir: nil, notify: false)
      @watcher = BBSit::Watcher.new(framework, directories: watch_dir, notify: notify)
    end

    def run
      @watcher.watch
    rescue SystemExit, Interrupt
      puts "\nBye bye!".blue
      exit
    end
  end
end
