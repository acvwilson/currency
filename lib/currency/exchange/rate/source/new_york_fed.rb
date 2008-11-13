# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'currency/exchange/rate/source/base'

require 'net/http'
require 'open-uri'
require 'rexml/document'


# Connects to http://www.newyorkfed.org/markets/fxrates/FXtoXML.cfm
# ?FEXdate=2007%2D02%2D14%2000%3A00%3A00%2E0&FEXtime=1200 and parses XML.
#
# No rates are available on Saturday and Sunday.
#
class Currency::Exchange::Rate::Source::NewYorkFed < ::Currency::Exchange::Rate::Source::Provider
  # Defines the pivot currency for http://xe.com/.
  PIVOT_CURRENCY = :USD
  
  def initialize(*opt)
    self.uri = 'http://www.newyorkfed.org/markets/fxrates/FXtoXML.cfm?FEXdate=#{date_YYYY}%2D#{date_MM}%2D#{date_DD}%2000%3A00%3A00%2E0&FEXTIME=1200'
    @raw_rates = nil
    super(*opt)
  end
  

  # Returns 'newyorkfed.org'.
  def name
    'newyorkfed.org'
  end


  # New York Fed rates are not available on Saturday and Sunday.
  def available?(time = nil)
    time ||= Time.now
    ! [0, 6].include?(time.wday) ? true : false
  end


  def clear_rates
    @raw_rates = nil
    super
  end
  

  def raw_rates
    rates
    @raw_rates
  end
  

  # The fed swaps rates on some currency pairs!
  # See http://www.newyorkfed.org/markets/fxrates/noon.cfm (LISTS AUD!)
  # http://www.newyorkfed.org/xml/fx.html (DOES NOT LIST AUD!)
  @@swap_units = {
    :AUD => true,
    :EUR => true,
    :NZD => true,
    :GBP => true,
  }


  # Parses XML for rates.
  def parse_rates(data = nil)
    data = get_page_content unless data
    
    rates = [ ]

    @raw_rates = { }

    $stderr.puts "#{self}: parse_rates: data =\n#{data}" if @verbose

    doc = REXML::Document.new(data).root
    x_series = doc.elements.to_a('//frbny:Series')
    raise ParserError, "no UNIT attribute" unless x_series
    x_series.each do | series |
      c1 = series.attributes['UNIT'] # WHAT TO DO WITH @UNIT_MULT?
      raise ParserError, "no UNIT attribute" unless c1
      c1 = c1.upcase.intern

      c2 = series.elements.to_a('frbny:Key/frbny:CURR')[0].text
      raise ParserError, "no frbny:CURR element" unless c2
      c2 = c2.upcase.intern
      
      rate = series.elements.to_a('frbny:Obs/frbny:OBS_VALUE')[0]
      raise ParserError, 'no frbny:OBS_VALUE' unless rate
      rate = rate.text.to_f

      date = series.elements.to_a('frbny:Obs/frbny:TIME_PERIOD')[0]
      raise ParserError, 'no frbny:TIME_PERIOD' unless date
      date = date.text
      date = Time.parse("#{date} 12:00:00 -05:00") # USA NY => EST

      # Handle arbitrary rate reciprocals!
      if @@swap_units[c1] || @@swap_units[c2]
        c1, c2 = c2, c1
      end

      rates << new_rate(c1, c2, rate, date)

      (@raw_rates[c1] ||= { })[c2] ||= rate
      (@raw_rates[c2] ||= { })[c1] ||= 1.0 / rate
    end

    # $stderr.puts "rates = #{rates.inspect}"
    raise ::Currency::Exception::UnavailableRates, 
    [
     "No rates found in #{get_uri.inspect}",
     :uri, get_uri,
    ] if rates.empty?

    rates
  end
  
  
  # Return a list of known base rates.
  def load_rates(time = nil)
    # $stderr.puts "#{self}: load_rates(#{time})" if @verbose
    self.date = time
    parse_rates
  end
  
 
end # class



