require 'filewatcher'
require 'open3'

module BBSit
  CODE_DIRECTORIES = %w[app lib].freeze

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

  # BBSitter knows how to watch for changes in code and look for corresponding tests
  # under a spec/ or test/ folder.  If found, it will run tests.
  class BBSitter
    def initialize(framework: 'rspec', watch: CODE_DIRECTORIES)
      @framework = FRAMEWORKS[framework.to_sym]
      @watch = watch
    end

    def watch_patterns
      patterns = @watch.map { |dir| File.join(dir, '**/*.rb') }
      patterns + [File.join(@framework[:dir], "**/*#{@framework[:suffix]}")]
    end

    def disect_path(filename)
      regex = /^(?<absolute_path>.*)\/(#{@watch.join('|')})\/(?<local_path>.*)\/(?<file>.*\.rb)/
      regex.match(filename)
    end

    def get_test_path(filename)
      captures = disect_path(filename)
      File.join(
        captures[:absolute_path],
        @framework[:dir],
        captures[:local_path],
        captures[:file].gsub('.rb', @framework[:suffix])
      )
    end

    def run_test(filename)
      cmd = "#{@framework[:cmd]} #{filename}"
      puts "Running \"#{cmd}\"..."
      Open3.popen3(cmd) do |_stdout, stderr, _status, _thread|
        while (line = stderr.gets)
          puts line
        end
      end
    end

    def run
      puts 'Listening for changes...'

      Filewatcher.new(watch_patterns).watch do |filename, _event|
        if /#{@framework[:suffix]}$/ =~ filename
          run_test(filename)
        else
          test_path = get_test_path(filename)
          if File.exist?(test_path)
            run_test(test_path)
          else
            puts "No test found at #{test_path}"
          end
        end

        puts 'Listening for changes...'
      end
    end
  end
end
