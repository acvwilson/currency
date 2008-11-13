# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'currency/exchange/rate'

#
# The Currency::Exchange::Rate::Source package is responsible for
# providing rates between currencies at a given time.
#
# It is not responsible for purchasing or selling actual money.
# See Currency::Exchange.
#
# Currency::Exchange::Rate::Source::Provider subclasses are true rate data
# providers.  See the #load_rates method.  They provide groups of rates
# at a given time.
#
# Other Currency::Exchange::Rate::Source::Base subclasses
# are chained to provide additional rate source behavior,
# such as caching and derived rates.  They provide individual rates between
# currencies at a given time.  See the #rate method.  An application
# will interface directly to a Currency::Exchange::Rate::Source::Base.
# A rate aggregator like Currency::Exchange::Rate::Historical::Writer will
# interface directly to a Currency::Exchange::Rate::Source::Provider.
#
# == IMPORTANT
#
# Rates sources should *never* install themselves
# as a Currency::Exchange::Rate::Source.current or
# Currency::Exchange::Rate::Source.default.  The application itself is
# responsible setting up the default rate source.
# The old auto-installation behavior of rate sources,
# like Currency::Exchange::Xe, is no longer supported.
#
# == Initialization of Rate Sources
#
# A typical application will use the following rate source chain:
#
# * Currency::Exchange::Rate::Source::TimedCache
# * Currency::Exchange::Rate::Deriver
# * a Currency::Exchange::Rate::Source::Provider subclass, like Currency::Exchange::Rate::Source::Xe.
#
# Somewhere at initialization of application:
#
#    require 'currency'
#    require 'currency/exchange/rate/deriver'
#    require 'currency/exchange/rate/source/xe'
#    require 'currency/exchange/rate/source/timed_cache'
# 
#    provider = Currency::Exchange::Rate::Source::Xe.new
#    deriver  = Currency::Exchange::Rate::Deriver.new(:source => provider)
#    cache    = Currency::Exchange::Rate::Source::TimedCache.new(:source => deriver)
#    Currency::Exchange::Rate::Source.default = cache
#
module Currency::Exchange::Rate::Source

    @@default = nil
    @@current = nil

    # Returns the default Currency::Exchange::Rate::Source::Base object.
    #
    # If one is not specfied an instance of Currency::Exchange::Rate::Source::Base is
    # created.  Currency::Exchange::Rate::Source::Base cannot service any
    # conversion rate requests.
    def self.default 
      @@default ||= Base.new
    end

    # Sets the default Currency::Exchange object.
    def self.default=(x)
      @@default = x
    end

    # Returns the current Currency::Exchange object used during
    # explicit and implicit Money conversions.
    # 
    # If #current= has not been called and #default= has not been called,
    # then UndefinedExchange is raised.
    def self.current
      @@current || self.default || (raise ::Currency::Exception::UndefinedExchange, "Currency::Exchange.current not defined")
    end

    # Sets the current Currency::Exchange object used during
    # explicit and implicit Money conversions.
    def self.current=(x)
      @@current = x
    end
end

require 'currency/exchange/rate/source/base'
