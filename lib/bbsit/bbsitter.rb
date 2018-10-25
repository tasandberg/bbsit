require 'filewatcher'
require 'open3'
require 'terminal-notifier'

module BBSit
  CODE_DIRECTORIES = %w(app lib).freeze

  FRAMEWORKS = {
    rspec: {
      cmd: 'bundle exec rspec --tty',
      dir: 'spec',
      suffix: '_spec.rb'
    },
    minitest: {
      cmd: 'bundle exec rake test',
      dir: 'test',
      suffix: '_test.rb'
    }
  }.freeze

  # BBSitter watches for changes in code and looks for corresponding tests to run.
  class BBSitter
    def initialize(framework: 'rspec', watch: CODE_DIRECTORIES, notify: false)
      @framework = FRAMEWORKS[framework.to_sym]
      @watch = watch
      @notify = notify
    end

    def watch_patterns
      current_dir = Dir.pwd
      patterns = @watch.map { |dir| File.join(current_dir, dir, '**/*.rb') }
      patterns + [File.join(current_dir, @framework[:dir], "**/*#{@framework[:suffix]}")]
    end

    def disect_path(filename)
      regex = /^(.*)\/(#{@watch.join('|')})\/(.*\.rb)/
      regex.match(filename)
    end

    def get_test_path(filename)
      captures = disect_path(filename)

      File.join(
        captures[1],
        @framework[:dir],
        captures[3].gsub('.rb', @framework[:suffix])
      )
    end

    def run_test(filename)
      cmd = "#{@framework[:cmd]} #{filename}"
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

    def notify(output_lines)
      TerminalNotifier.notify(
        'bbsit',
        subtitle: 'Run complete',
        title: output_lines.last.chomp,
        appIcon: File.join(BBSit.root, 'lib', 'images', 'girlbaby.png')
      )
    end

    def run
      Filewatcher.new(watch_patterns, spinner: true).watch do |filename, _event|
        log "Change detected: #{filename}"
        if /#{@framework[:suffix]}$/ =~ filename
          run_test(filename)
        else
          test_path = get_test_path(filename)
          if File.exist?(test_path)
            output = run_test(test_path)
            notify(output) if @notify
          else
            log "No test found at #{test_path}"
          end
        end
      end
    end

    def log(str, color = :yellow)
      puts str.send(color)
    end
  end
end
