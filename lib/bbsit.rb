require 'bbsit/version'
require 'bbsit/bbsitter'
require 'bbsit/colors'

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
  def self.root
    File.dirname __dir__
  end
end