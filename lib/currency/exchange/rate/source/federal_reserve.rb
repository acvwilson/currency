# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'currency/exchange/rate/source/provider'

require 'net/http'
require 'open-uri'


# Connects to http://www.federalreserve.gov/releases/H10/hist/dat00_<country>.txtb
# Parses all known currency files.
# 
class Currency::Exchange::Rate::Source::FederalReserve < ::Currency::Exchange::Rate::Source::Provider
  # Defines the pivot currency for http://www.federalreserve.gov/releases/H10/hist/dat00_#{country_code}.txt data files.
  PIVOT_CURRENCY = :USD
  
  # Arbitrary currency code used by www.federalreserve.gov for
  # naming historical data files.
  # Used internally.
  attr_accessor :country_code

  def initialize(*opt)
    self.uri = 'http://www.federalreserve.gov/releases/H10/hist/dat00_#{country_code}.txt'
    self.country_code = '' 
    @raw_rates = nil
    super(*opt)
  end
  

  # Returns 'federalreserve.gov'.
  def name
    'federalreserve.gov'
  end


  # FIXME?
  #def available?(time = nil)
  #  time ||= Time.now
  #  ! [0, 6].include?(time.wday) ? true : false
  #end


  def clear_rates
    @raw_rates = nil
    super
  end
  

  def raw_rates
    rates
    @raw_rates
  end

  # Maps bizzare federalreserve.gov country codes to ISO currency codes.
  # May only work for the dat00_XX.txt data files.
  # See http://www.jhall.demon.co.uk/currency/by_country.html
  #
  # Some data files list reciprocal rates!
  @@country_to_currency = 
    {
    'al' => [ :AUD, :USD ],
    # 'au' => :ASH, # AUSTRIAN SHILLING: pre-EUR?
    'bz' => [ :USD, :BRL ],
    'ca' => [ :USD, :CAD ],
    'ch' => [ :USD, :CNY ],
    'dn' => [ :USD, :DKK ],
    'eu' => [ :EUR, :USD ],
    # 'gr' => :XXX, # Greece Drachma: pre-EUR?
    'hk' => [ :USD, :HKD ],
    'in' => [ :USD, :INR ],
    'ja' => [ :USD, :JPY ],
    'ma' => [ :USD, :MYR ],
    'mx' => [ :USD, :MXN ], # OR MXP?
    'nz' => [ :NZD, :USD ],
    'no' => [ :USD, :NOK ],
    'ko' => [ :USD, :KRW ],
    'sf' => [ :USD, :ZAR ],
    'sl' => [ :USD, :LKR ],
    'sd' => [ :USD, :SEK ],
    'sz' => [ :USD, :CHF ],
    'ta' => [ :USD, :TWD ], # New Taiwan Dollar.
    'th' => [ :USD, :THB ],
    'uk' => [ :GBP, :USD ],
    've' => [ :USD, :VEB ],
  }


  # Parses text file for rates.
  def parse_rates(data = nil)
    data = get_page_content unless data
    
    rates = [ ]

    @raw_rates ||= { }

    $stderr.puts "#{self}: parse_rates: data =\n#{data}" if @verbose

    # Rates are USD/currency so
    # c1 = currency
    # c2 = :USD
    c1, c2 = @@country_to_currency[country_code]

    unless c1 && c2
      raise ::Currency::Exception::UnavailableRates, "Cannot determine currency code for federalreserve.gov country code #{country_code.inspect}"
    end

    data.split(/\r?\n\r?/).each do | line |
      #        day     month             yy       rate
      m = /^\s*(\d\d?)-([A-Z][a-z][a-z])-(\d\d)\s+([\d\.]+)/.match(line)
      next unless m
      
      day = m[1].to_i
      month = m[2]
      year = m[3].to_i
      if year >= 50 and year < 100
        year += 1900
      elsif year < 50
        year += 2000
      end
      
      date = Time.parse("#{day}-#{month}-#{year} 12:00:00 -05:00") # USA NY => EST

      rate = m[4].to_f

      STDERR.puts "#{c1} #{c2} #{rate}\t#{date}" if @verbose

      rates << new_rate(c1, c2, rate, date)

      ((@raw_rates[date] ||= { })[c1] ||= { })[c2] ||= rate
      ((@raw_rates[date] ||= { })[c2] ||= { })[c1] ||= 1.0 / rate
    end

    # Put most recent rate first.
    # See Provider#get_rate.
    rates.reverse!

    # $stderr.puts "rates = #{rates.inspect}"
    raise ::Currency::Exception::UnavailableRates, "No rates found in #{get_uri.inspect}" if rates.empty?

    rates
  end
  
  
  # Return a list of known base rates.
  def load_rates(time = nil)
    # $stderr.puts "#{self}: load_rates(#{time})" if @verbose
    self.date = time
    rates = [ ]
    @@country_to_currency.keys.each do | cc |
      self.country_code = cc
      rates.push(*parse_rates)
    end
    rates
  end
  
 
end # class



