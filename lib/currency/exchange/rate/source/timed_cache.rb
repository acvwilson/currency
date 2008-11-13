# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'currency/exchange/rate/source/base'

# A timed cache for rate sources.
#
# This class should be used at the top-level of a rate source change,
# to correctly check rate dates.
#
class Currency::Exchange::Rate::Source::TimedCache < ::Currency::Exchange::Rate::Source::Base
  # The rate source.
  attr_accessor :source
  
  # Defines the number of seconds rates until rates
  # become invalid, causing a request of new rates.
  #
  # Defaults to 600 seconds.
  attr_accessor :time_to_live
  
  
  # Defines the number of random seconds to add before
  # rates become invalid.
  #
  # Defaults to 30 seconds.
  attr_accessor :time_to_live_fudge


  # Returns the time of the last load.
  attr_reader :rate_load_time


  # Returns the time of the next load.
  attr_reader :rate_reload_time
  

  # Returns source's name.
  def name
    source.name
  end
  
  
  def initialize(*opt)
    self.time_to_live = 600
    self.time_to_live_fudge = 30
    @rate_load_time = nil
    @rate_reload_time = nil
    @processing_rates = false
    @cached_rates = { }
    @cached_rates_old = nil
    super(*opt)
  end
  
  
  # Clears current rates.
  def clear_rates
    @cached_rates = { }
    @source.clear_rates
    super
  end
  
  
  # Returns true if the cache of Rates
  # is expired.
  def expired?
    if @time_to_live &&
        @rate_reload_time &&
        (Time.now > @rate_reload_time)
      
      if @cached_rates 
        $stderr.puts "#{self}: rates expired on #{@rate_reload_time}" if @verbose
        
        @cached_rates_old = @cached_rates
      end
  
      clear_rates
      
      true
    else
      false
    end
  end
  
  
  # Check expired? before returning a Rate.
  def rate(c1, c2, time)
    if expired?
      clear_rates
    end
    super(c1, c2, time)
  end


  def get_rate(c1, c2, time)
    # STDERR.puts "get_rate #{c1} #{c2} #{time}"
    rates = load_rates(time)
    # STDERR.puts "rates = #{rates.inspect}"
    rate = rates && (rates.select{|x| x.c1 == c1 && x.c2 == c2}[0])
    # STDERR.puts "rate = #{rate.inspect}"
    rate
  end
  

  # Returns an array of all the cached Rates.
  def rates(time = nil)
    load_rates(time)
  end


  # Returns an array of all the cached Rates.
  def load_rates(time = nil)
    # Check expiration.
    expired?
    
    # Return rates, if cached.
    return rates if rates = @cached_rates["#{time}"]
    
    # Force load of rates.
    rates = @cached_rates["#{time}"] = _load_rates_from_source(time)
    
    # Update expiration.
    _calc_rate_reload_time

    return nil unless rates

    # Flush old rates.
    @cached_rates_old = nil
        
    rates
  end
  

  def time_to_live=(x)
    @time_to_live = x
    _calc_rate_reload_time
    x
  end


  def time_to_live_fudge=(x)
    @time_to_live_fudge = x
    _calc_rate_reload_time
    x
  end


  def _calc_rate_reload_time
    if @time_to_live && @rate_load_time
      @rate_reload_time = @rate_load_time + (@time_to_live + (@time_to_live_fudge || 0))
      $stderr.puts "#{self}: rates expire on #{@rate_reload_time}" if @verbose
    end

  end



  def _load_rates_from_source(time = nil) # :nodoc:
    rates = nil

    begin
      # Do not allow re-entrancy
      raise Currency::Exception::InvalidReentrancy, "Reentry!" if @processing_rates
      
      # Begin processing new rate request.
      @processing_rates = true

      # Clear cached Rates.
      clear_rates

      # Load rates from the source.
      rates = source.load_rates(time)
      
      # Compute new rate timestamp.
      @rate_load_time = Time.now

      # STDERR.puts "rate_load_time = #{@rate_load_time}"
    ensure
      # End processsing new rate request.
      @processing_rates = false
    
    end

    # STDERR.puts "_load_rates => #{rates.inspect}"

    rates
  end


  # Returns true if the underlying rate provider is available.
  def available?(time = nil)
    source.available?(time)
  end


end # class



