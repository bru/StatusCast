#
#  interval.rb
#  StatusCast
#
#  Created by Riccardo Cambiassi on 14/04/2011.
#  Copyright 2011 __MyCompanyName__. All rights reserved.
#

class Interval
  class InvalidInterval < Exception; end
  
  attr_accessor :label, :seconds
  
  @@intervals = []
  
  def self.all
    return @@intervals if @@intervals.size > 0
    @@intervals.clear
  
    intervals = {
      "30 seconds"  =>  30,
      "1 minute"    =>  60, 
      "2 minutes"   => 120,
      "5 minutes"   => 300,
      "10 minutes"  => 600
    }
    intervals.keys.sort.each do |seconds|
      @@intervals << new(:seconds => intervals[seconds], :label => seconds)
    end

    @@intervals
  end

  def self.find_with_label(label)
    valid = all.select do |interval|
      interval.label == label
    end
    valid.first
  end

  def initialize(options)
    raise InvalidInterval unless options[:seconds] && options[:label]
    @seconds = options[:seconds]
    @label   = options[:label]
  end

end
