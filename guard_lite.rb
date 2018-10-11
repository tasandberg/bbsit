# frozen_string_literal: true

require 'filewatcher'
require 'open3'

WATCH_PATTERNS = %w[
  spec/**/*_spec.rb
  app/**/*.rb
].freeze

# Utility Methods

def get_test_path(filename)
  absolute_path, path, file = %r{(.*)\/app|lib\/(.*)(\/.*.rb)}.match(filename).captures
  File.join(absolute_path, 'spec', path, file.gsub('.rb', '_spec.rb'))
end

def run_test(filename)
  cmd = "bundle exec rspec --tty #{filename}"
  puts "Running \"#{cmd}\"..."
  Open3.popen3(cmd) do |_stdout, stderr, _status, _thread|
    while (line = stderr.gets)
      puts line
    end
  end
end

# Watch files and run tests

Filewatcher.new(WATCH_PATTERNS).watch do |filename, _event|
  if /_spec.rb$/ =~ filename
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
