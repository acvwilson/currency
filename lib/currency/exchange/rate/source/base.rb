# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'currency/exchange/rate/source'

# = Currency::Exchange::Rate::Source::Base
#
# The Currency::Exchange::Rate::Source::Base class is the base class for
# currency exchange rate providers.
#
# Currency::Exchange::Rate::Source::Base subclasses are Currency::Exchange::Rate
# factories.
#
# Represents a method of converting between two currencies.
#
# See Currency;:Exchange::Rate::source for more details.
#
class Currency::Exchange::Rate::Source::Base

    # The name of this Exchange.
    attr_accessor :name

    # Currency to use as pivot for deriving rate pairs.
    # Defaults to :USD.
    attr_accessor :pivot_currency

    # If true, this Exchange will log information.
    attr_accessor :verbose

    attr_accessor :time_quantitizer


    def initialize(opt = { })
      @name = nil
      @verbose = nil unless defined? @verbose
      @pivot_currency ||= :USD

      @rate = { }
      @currencies = nil
      opt.each_pair{|k,v| self.send("#{k}=", v)}
    end 


    def __subclass_responsibility(meth)
      raise ::Currency::Exception::SubclassResponsibility, 
      [
       "#{self.class}#\#{meth}", 
       :class, self.class, 
       :method, method,
      ]
    end


    # Converts Money m in Currency c1 to a new
    # Money value in Currency c2.
    def convert(m, c2, time = nil, c1 = nil)
      c1 = m.currency if c1 == nil
      time = m.time if time == nil
      time = normalize_time(time)
      if c1 == c2 && normalize_time(m.time) == time
        m
      else
        rate = rate(c1, c2, time)
        # raise ::Currency::Exception::UnknownRate, "#{c1} #{c2} #{time}" unless rate
          
        rate && ::Currency::Money(rate.convert(m, c1), c2, time)
      end
    end


    # Flush all cached Rate.
    def clear_rates
      @rate.clear
      @currencies = nil
    end


    # Flush any cached Rate between Currency c1 and c2.
    def clear_rate(c1, c2, time, recip = true)
      time = time && normalize_time(time)
      @rate["#{c1}:#{c2}:#{time}"] = nil
      @rate["#{c2}:#{c1}:#{time}"] = nil if recip
      time
    end


    # Returns the cached Rate between Currency c1 and c2 at a given time.
    #
    # Time is normalized using #normalize_time(time)
    #
    # Subclasses can override this method to implement
    # rate expiration rules.
    #
    def rate(c1, c2, time)
      time = time && normalize_time(time)
      @rate["#{c1}:#{c2}:#{time}"] ||= get_rate(c1, c2, time)
    end


    # Gets all rates available by this source.
    #
    def rates(time = nil)
      __subclass_responsibility(:rates)
    end


    # Returns a list of Currencies that the rate source provides.
    #
    # Subclasses can override this method.
    def currencies
      @currencies ||= rates.collect{| r | [ r.c1, r.c2 ]}.flatten.uniq
    end


    # Determines and creates the Rate between Currency c1 and c2.
    #
    # May attempt to use a pivot currency to bridge between
    # rates.
    #
    def get_rate(c1, c2, time)
      __subclass_responsibility(:get_rate)
    end

    # Returns a base Rate.
    #
    # Subclasses are required to implement this method.
    def get_rate_base(c1, c2, time)
      __subclass_responsibility(:get_rate_base)
    end


    # Returns a list of all available rates.
    #
    # Subclasses must override this method.
    def get_rates(time = nil)
      __subclass_responsibility(:get_rates)
    end


    # Called by implementors to construct new Rate objects.
    def new_rate(c1, c2, c1_to_c2_rate, time = nil, derived = nil)
      c1 = ::Currency::Currency.get(c1)
      c2 = ::Currency::Currency.get(c2)
      rate = ::Currency::Exchange::Rate.new(c1, c2, c1_to_c2_rate, name, time, derived)
      # $stderr.puts "new_rate = #{rate}"
      rate
    end


    # Normalizes rate time to a quantitized value.
    #
    # Subclasses can override this method.
    def normalize_time(time)
      time && (time_quantitizer || ::Currency::Exchange::TimeQuantitizer.current).quantitize_time(time)
    end
  
   
    # Returns a simple string rep.
    def to_s
      "#<#{self.class.name} #{self.name && self.name.inspect}>"
    end
    alias :inspect :to_s

end # class

  
