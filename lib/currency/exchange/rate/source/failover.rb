# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'currency/exchange/rate/source'


# Gets Rates from primary source, if primary fails, attempts secondary source.
#
class Currency::Exchange::Rate::Source::Failover < ::Currency::Exchange::Base
  # Primary rate source.
  attr_accessor :primary

  # Secondary rate source if primary fails.
  attr_accessor :secondary

  def name
    "failover(#{primary.name}, #{secondary.name})"
  end


  def clear_rates
    @primary.clear_rates
    @secondary.clear_rates
    super
  end
  

  def get_rate(c1, c2, time)
    rate = nil

    # Try primary.
    err = nil
    begin
      rate = @primary.get_rate(c1, c2, time)
    rescue Object => e
      err = e
    end


    if rate == nil || err
      $stderr.puts "Failover: primary failed for get_rate(#{c1}, #{c2}, #{time}) : #{err.inspect}"
      rate = @secondary.get_rate(c1, c2, time)
    end


    unless rate
      raise Currency::Exception::UnknownRate, 
      [ 
       "Failover: secondary failed for get_rate(#{c1}, #{c2}, #{time})", 
       :c1, c1,
       :c2, c2, 
       :time, time,
      ]
    end

    rate
  end

 
end # class



