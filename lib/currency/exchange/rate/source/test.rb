# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'currency/exchange/rate/source/provider'

# This class is a test Rate Source.
# It can provide only fixed rates between USD, CAD and EUR.
# Used only for test purposes.
# DO NOT USE THESE RATES FOR A REAL APPLICATION.
class Currency::Exchange::Rate::Source::Test < Currency::Exchange::Rate::Source::Provider
    @@instance = nil

    # Returns a singleton instance.
    def self.instance(*opts)
      @@instance ||= self.new(*opts)
    end


    def initialize(*opts)
     self.uri = 'none://localhost/Test'
     super(*opts)
    end


    def name
      'Test'
    end

    # Test rate from :USD to :CAD.
    def self.USD_CAD; 1.1708; end


    # Test rate from :USD to :EUR.
    def self.USD_EUR; 0.7737; end


    # Test rate from :USD to :GBP.
    def self.USD_GBP; 0.5098; end


    # Returns test Rate for USD to [ CAD, EUR, GBP ]. 
    def rates
      [ new_rate(:USD, :CAD, self.class.USD_CAD),
        new_rate(:USD, :EUR, self.class.USD_EUR),
        new_rate(:USD, :GBP, self.class.USD_GBP) ]
    end

end # class


