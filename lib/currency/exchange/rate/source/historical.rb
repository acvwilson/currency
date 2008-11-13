# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'currency/exchange/rate/source/base'

# Gets historical rates from database using Active::Record.
# Rates are retrieved using Currency::Exchange::Rate::Source::Historical::Rate as
# a database record proxy.
#
# See Currency::Exchange::Rate::Source::Historical::Writer for a rate archiver.
#
class Currency::Exchange::Rate::Source::Historical < Currency::Exchange::Rate::Source::Base

    # Select specific rate source.
    # Defaults to nil
    attr_accessor :source

    def initialize
      @source = nil # any
      super
    end


    def source_key
      @source ? @source.join(',') : ''
    end


    # This Exchange's name is the same as its #uri.
    def name
      "historical #{source_key}"
    end


    def initialize(*opt)
      super
      @rates_cache = { }
      @raw_rates_cache = { }
    end


    def clear_rates
      @rates_cache.clear
      @raw_rates_cache.clear
      super
    end


    # Returns a Rate.
    def get_rate(c1, c2, time)
      # rate = 
      get_rates(time).select{ | r | r.c1 == c1 && r.c2 == c2 }[0]
      # $stderr.puts "#{self}.get_rate(#{c1}, #{c2}, #{time.inspect}) => #{rate.inspect}"
      # rate
    end


    # Return a list of base Rates.
    def get_rates(time = nil)
      @rates_cache["#{source_key}:#{time}"] ||= 
        get_raw_rates(time).collect do | rr |
          rr.to_rate
        end
    end


    # Return a list of raw rates.
    def get_raw_rates(time = nil)
      @raw_rates_cache["#{source_key}:#{time}"] ||= 
        ::Currency::Exchange::Rate::Source::Historical::Rate.new(:c1 => nil, :c2 => nil, :date => time, :source => source).
          find_matching_this(:all)
    end

end # class


require 'currency/exchange/rate/source/historical/rate'


