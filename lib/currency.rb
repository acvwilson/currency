# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
#
# See LICENSE.txt for details.
#
# = Currency
#
# The Currency package provides an object-oriented model of:
#
# * currencies 
# * exchanges
# * exchange rates
# * exchange rate sources
# * monetary values
#
# The core classes are:
#
# * Currency::Money - uses a scaled integer representation of a monetary value and performs accurate conversions to and from string values.
# * Currency::Currency - provides an object-oriented representation of a currency.
# * Currency::Exchange::Base - the base class for a currency exchange rate provider.
# * Currency::Exchange::Rate::Source::Base - the base class for an on-demand currency exchange rate data provider.
# * Currency::Exchange::Rate::Source::Provider - the base class for a bulk exchange rate data provider.
# * Currency::Exchange::Rate - represents a exchange rate between two currencies.
#
# 
# The example below uses Currency::Exchange::Xe to automatically get 
# exchange rates from http://xe.com/ :
#
#    require 'currency'
#    require 'currency/exchange/rate/deriver'
#    require 'currency/exchange/rate/source/xe'
#    require 'currency/exchange/rate/source/timed_cache'
#    
#    # Rate source initialization
#    provider = Currency::Exchange::Rate::Source::Xe.new
#    deriver  = Currency::Exchange::Rate::Deriver.new(:source => provider)
#    cache = Currency::Exchange::Rate::Source::TimedCache.new(:source => deriver)
#    Currency::Exchange::Rate::Source.default = cache
#
#    usd = Currency::Money('6.78', :USD)
#    puts "usd = #{usd.format}"
#    cad = usd.convert(:CAD)
#    puts "cad = #{cad.format}"
#
# == ActiveRecord Suppport
#
# This package also contains ActiveRecord support for money values:
#
#    require 'currency'
#    require 'currency/active_record'
#    
#    class Entry < ActiveRecord::Base
#       money :amount
#    end
# 
# In the example above, the entries.amount database column is an INTEGER that represents US cents. 
# The currency code of the money value can be stored in an additional database column or a default currency can be used.
#
# == Recent Enhancements
#
# === Storage and retrival of historical exchange rates
#
# * See Currency::Exchange::Rate::Source::Historical
# * See Currency::Exchange::Rate::Source::Historical::Writer
#
# === Automatic derivation of rates from base rates.
#
# * See Currency::Exchange::Rate::Deriver
#
# === Rate caching
#
# * See Currency::Exchange::Rate::Source::TimedCache
#
# === Rate Providers
#
# * See Currency::Exchange::Rate::Source::Xe
# * See Currency::Exchange::Rate::Source::NewYorkFed
# * See Currency::Exchange::Rate::Source::TheFinancials
#
# === Customizable formatting and parsing
#
# * See Currency::Formatter
# * See Currency::Parser
#
# == Future Enhancements
#
# * Support for inflationary rates within a currency, e.g. $10 USD in the year 1955 converted to 2006 USD.
# 
# == SVN Repo
#
#    svn checkout svn://rubyforge.org/var/svn/currency/currency/trunk
#
# == Examples
#
# See the examples/ and test/ directorys
#
# == Author
#
# Kurt Stephens http://kurtstephens.com
#
# == Support
#
# http://rubyforge.org/forum/forum.php?forum_id=7643
#
# == Copyright
#
# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
#
# See LICENSE.txt for details.
#
module Currency
  # Use this function instead of Money#new:
  #
  #    Currency::Money("12.34", :CAD)
  #
  # Do not do this:
  #
  #    Currency::Money.new("12.34", :CAD)
  #
  # See Money#new.
  def self.Money(*opts)
    Money.new(*opts)
  end
end

$:.unshift(File.expand_path(File.dirname(__FILE__))) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'currency/currency_version'
require 'currency/config'
require 'currency/exception'
require 'currency/money'
require 'currency/currency'
require 'currency/currency/factory'
require 'currency/money'
require 'currency/formatter'
require 'currency/parser'
require 'currency/exchange'
require 'currency/exchange/rate'
require 'currency/exchange/rate/deriver'
require 'currency/exchange/rate/source'
require 'currency/exchange/rate/source/test'
require 'currency/exchange/time_quantitizer'
require 'currency/core_extensions'

