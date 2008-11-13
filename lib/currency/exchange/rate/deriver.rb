# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'currency/exchange/rate'
require 'currency/exchange/rate/source/base'

# The Currency::Exchange::Rate::Deriver class calculates derived rates
# from base Rates from a rate Source by pivoting against a pivot currency or by
# generating reciprocals.
#
class Currency::Exchange::Rate::Deriver < Currency::Exchange::Rate::Source::Base

  # The source for base rates.
  attr_accessor :source
  

  def name
    source.name
  end


  def initialize(opt = { })
    @source = nil
    @pivot_currency = nil
    @derived_rates = { }
    @all_rates = { }
    super
  end 


  def pivot_currency
    @pivot_currency || @source.pivot_currency || :USD
  end


  # Return all currencies.
  def currencies
    @source.currencies
  end


  # Flush all cached Rates.
  def clear_rates
    @derived_rates.clear
    @all_rates.clear
    @source.clear_rates
    super
  end
 

  # Returns all combinations of rates except identity rates.
  def rates(time = nil)
    time = time && normalize_time(time)
    all_rates(time)
  end


  # Computes all rates.
  # time is assumed to be normalized.
  def all_rates(time = nil)
    if x = @all_rates["#{time}"]
      return x 
    end

    x = @all_rates["#{time}"] = [ ]
    
    currencies = self.currencies

    currencies.each do | c1 |
      currencies.each do | c2 |
        next if c1 == c2 
        c1 = ::Currency::Currency.get(c1)
        c2 = ::Currency::Currency.get(c2)
        rate = rate(c1, c2, time)
        x << rate
      end
    end

    x
  end


  # Determines and creates the Rate between Currency c1 and c2.
  #
  # May attempt to use a pivot currency to bridge between
  # rates.
  #
  def get_rate(c1, c2, time)
    rate = get_rate_reciprocal(c1, c2, time)
    
    # Attempt to use pivot_currency to bridge
    # between Rates.
    unless rate
      pc = ::Currency::Currency.get(pivot_currency)
      
      if pc &&
          (rate_1 = get_rate_reciprocal(c1, pc, time)) && 
          (rate_2 = get_rate_reciprocal(pc, c2, time))
        c1_to_c2_rate = rate_1.rate * rate_2.rate
        rate = new_rate(c1, c2, 
                        c1_to_c2_rate, 
                        rate_1.date || rate_2.date || time, 
                        "pivot(#{pc.code},#{rate_1.derived || "#{rate_1.c1.code}#{rate_1.c2.code}"},#{rate_2.derived || "#{rate_2.c1}#{rate_2.c2}"})")
      end
    end
    
    rate
  end


  # Get a matching base rate or its reciprocal.
  def get_rate_reciprocal(c1, c2, time)
    rate = get_rate_base_cached(c1, c2, time)
    unless rate
      if rate = get_rate_base_cached(c2, c1, time)
        rate = (@rate["#{c1}:#{c2}:#{time}"] ||= rate.reciprocal)
      end
    end
    
    rate
  end


  # Returns a cached base Rate.
  #
  def get_rate_base_cached(c1, c2, time)
    rate = (@rate["#{c1}:#{c2}:#{time}"] ||= get_rate_base(c1, c2, time))
    rate
  end


  # Returns a base Rate from the Source.
  def get_rate_base(c1, c2, time)
    if c1 == c2
      # Identity rates are timeless.
      new_rate(c1, c2, 1.0, nil, "identity")
    else
      source.rate(c1, c2, time)
    end
  end


  def load_rates(time = nil)
    all_rates(time)
  end


  # Returns true if the underlying rate provider is available.
  def available?(time = nil)
    source.available?(time)
  end


end # class

  

