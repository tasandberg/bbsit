require 'bbsit/version'
require 'bbsit/test_runner'
require 'bbsit/watcher'
require 'bbsit/bbsitter'
require 'bbsit/colors'
require 'logger'

class Filewatcher
  module Cycles
    def watching_cycle
      while @keep_watching && !filesystem_updated? && !@pausing
        label = 'BBSitting'
        update_spinner(label.blue)
        sleep @interval
      end
    end
  end
end

module BBSit
  def self.log(str, color = :yellow)
    puts str.send(color)
  end

  def self.root
    File.dirname __dir__
  end
end
