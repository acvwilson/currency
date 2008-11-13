# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

# = Currency::Exchange::TimeQuantitizer
#
# The Currency::Exchange::TimeQuantitizer quantitizes time values
# such that money values and rates at a given time
# can be turned into a hash key, depending
# on the rate source's temporal accuracy.
#
class Currency::Exchange::TimeQuantitizer

  def self.current; @current ||= self.new; end
  def self.current=(x); @current = x; end

  # Time quantitization size.
  # Defaults to 1 day.
  attr_accessor :time_quant_size

  # Time quantization offset in seconds.
  # This is applied to epoch time before quantization.
  # If nil, uses Time#utc_offset.
  # Defaults to nil.
  attr_accessor :time_quant_offset
  
  def initialize(*opt)
    @time_quant_size   ||= 60 * 60 * 24
    @time_quant_offset ||= nil
    opt = Hash[*opt]
    opt.each_pair{|k,v| self.send("#{k}=", v)}
  end 
  
  
  # Normalizes time to a quantitized value.
  # For example: a time_quant_size of 60 * 60 * 24 will
  # truncate a rate time to a particular day.
  #
  # Subclasses can override this method.
  def quantitize_time(time)
    # If nil, then nil.
    return time unless time

    # Get bucket parameters.
    was_utc = time.utc?
    quant_offset = time_quant_offset
    quant_offset ||= time.utc_offset
    # $stderr.puts "quant_offset = #{quant_offset}"
    quant_size = time_quant_size.to_i
    
    # Get offset from epoch.
    time = time.tv_sec
    
    # Remove offset (timezone)
    time += quant_offset
    
    # Truncate to quantitize size.
    time = (time.to_i / quant_size) * quant_size
    
    # Add offset (timezone)
    time -= quant_offset
    
    # Convert back to Time object.
    time = Time.at(time)
    
    # Quant to day?
    # NOTE: is this due to a Ruby bug, or
    # some wierd UTC time-flow issue, like leap-seconds.
    if quant_size == 60 * 60 * 24 
      time = time + 60 * 60
      if was_utc
        time = time.getutc
        time = Time.utc(time.year, time.month, time.day, 0, 0, 0, 0)
      else
        time = Time.local(time.year, time.month, time.day, 0, 0, 0, 0)
      end
    end
    
    # Convert back to UTC?
    time = time.getutc if was_utc
    
    time
  end
  
  # Returns a Range of Time such that:
  #
  #   range.include?(time) 
  #   ! range.include?(time + time_quant_size)
  #   ! range.include?(time - time_quant_size)
  #   range.exclude_end?
  #
  # The range.max is end-exclusive to avoid precision issues:
  # 
  #  t = Time.now
  #   => Thu Feb 15 15:32:34 EST 2007
  #  x.quantitize_time_range(t)
  #   => Thu Feb 15 00:00:00 EST 2007...Fri Feb 16 00:00:00 EST 2007
  #
  def quantitize_time_range(time)
    time_0 = quantitize_time(time)
    time_1 = time_0 + time_quant_size.to_i
    time_0 ... time_1
  end
  
  # Returns a simple string rep.
  def to_s
    "#<#{self.class.name} #{quant_offset} #{quant_size}>"
  end
  
end # class

  
