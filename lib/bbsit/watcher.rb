require 'filewatcher'

module BBSit
  class Watcher
    CODE_DIRECTORIES = %w(app lib).freeze

    FRAMEWORKS = {
      rspec: {
        cmd: 'bundle exec rspec --tty',
        dir: 'spec',
        test_file_suffix: '_spec.rb'
      },
      minitest: {
        cmd: 'bundle exec rake test',
        dir: 'test',
        test_file_suffix: '_test.rb'
      }
    }.freeze

    def initialize(framework, directories: nil, notify: false)
      @framework = FRAMEWORKS[framework.to_sym]
      @watch = directories || CODE_DIRECTORIES
      @test_runner = TestRunner.new(@framework[:cmd])
      @notify = notify
    end

    def watch
      Filewatcher.new(watch_patterns, spinner: true).watch &method(:file_event_handler)
    end

    def file_event_handler(filename, _event)
      BBSit.log "Change detected: #{filename}"
      test_path = get_test_path(filename)

      if File.exist?(test_path)
        output = @test_Runner.run(test_path)
        notify(output) if @notify
      else
        BBSit.log "No test found at #{test_path}"
      end
    end

    private

    def get_test_path(filename)
      if test_file_regexp =~ filename
        filename
      else
        captures = /^(.*)\/(#{@watch.join('|')})\/(.*\.rb)/.match(filename)

        File.join(
          captures[1],
          @framework[:dir],
          @framework[:dir] == 'spec' && captures[2] == 'lib' ? 'lib' : '',
          captures[3].gsub('.rb', @framework[:test_file_suffix])
        )
      end
    end

    def test_file_regexp
      /#{@framework[:test_file_suffix]}$/
    end

    def watch_patterns
      current_dir = Dir.pwd
      patterns = @watch.map { |dir| File.join(current_dir, dir, '**/*.rb') }
      patterns + [File.join(current_dir, @framework[:dir], "**/*#{@framework[:test_file_suffix]}")]
    end

    def notify(output_lines)
      TerminalNotifier.notify(
        'bbsit',
        subtitle: 'Run complete',
        title: output_lines.last.chomp,
        appIcon: File.join(BBSit.root, 'lib', 'images', 'girlbaby.png')
      )
    end
  end
end