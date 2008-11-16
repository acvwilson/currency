# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'spec'
require File.dirname(__FILE__) + '/../lib/currency'
require File.dirname(__FILE__) + '/../lib/currency/exchange/rate/source/test'

def setup(source = nil)
  rate_source ||= get_rate_source(source)
  Currency::Exchange::Rate::Source.default = rate_source

  # Force non-historical money values.
  Currency::Money.default_time = nil
end

def get_rate_source(source = nil)
  source ||= Currency::Exchange::Rate::Source::Test.instance
  Currency::Exchange::Rate::Deriver.new(:source => source)
end

Spec::Runner.configure do |config|
  config.before(:all) {setup}
end


