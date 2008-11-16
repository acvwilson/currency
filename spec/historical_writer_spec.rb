# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.
require File.dirname(__FILE__) + '/ar_spec_helper'

require File.dirname(__FILE__) + '/../lib/currency/exchange/rate/source/historical'
require File.dirname(__FILE__) + '/../lib/currency/exchange/rate/source/historical/writer'
require File.dirname(__FILE__) + '/../lib/currency/exchange/rate/source/xe'
require File.dirname(__FILE__) + '/../lib/currency/exchange/rate/source/new_york_fed'

include Currency
RATE_CLASS = Exchange::Rate::Source::Historical::Rate
TABLE_NAME = RATE_CLASS.table_name

class HistoricalRateMigration < ActiveRecord::Migration
  def self.up
    RATE_CLASS.__create_table(self)
  end

  def self.down
    drop_table TABLE_NAME.to_sym
  end
end

describe "HistoricalWriter" do
  before(:all) do
    ActiveRecord::Base.establish_connection(database_spec)
    @currency_test_migration ||= HistoricalRateMigration
    schema_down
    schema_up
    @xe_src  = Exchange::Rate::Source::Xe.new
    @fed_src = Exchange::Rate::Source::NewYorkFed.new
  end
  
  after(:all) do
    schema_down
  end
  
  def setup_writer(source)
    writer = Exchange::Rate::Source::Historical::Writer.new
    writer.time_quantitizer = :current
    writer.required_currencies = [ :USD, :GBP, :EUR, :CAD ]
    writer.base_currencies = [ :USD ]
    writer.preferred_currencies = writer.required_currencies
    writer.reciprocal_rates = true
    writer.all_rates = true
    writer.identity_rates = false
    writer.source = source
    writer
  end
  
  it "does stuff with a Xe writer" do
    writer = setup_writer(@xe_src)
    rates = writer.write_rates
    rates.size.should == 12
    assert_h_rates(rates, writer)
  end
  
  it "does stuff with NewYorkFed (will fail on weekends)" do
    if @fed_src.available?
      writer = setup_writer(@fed_src)
      rates = writer.write_rates
      rates.size.should == 12
      assert_h_rates(rates, writer)
    end
  end
  
  def assert_h_rates(rates, writer = nil)
    hr0 = rates[0]
    hr0.should_not be_nil
    rates.each do | hr |
      found_hr = nil
      begin
        found_hr = hr.find_matching_this(:first)
        found_hr.should_not be_nil
      rescue Object => err
        raise "#{hr.inspect}: #{err}:\n#{err.backtrace.inspect}"
      end
      assert_equal_rate(hr, found_hr)
      assert_rate_defaults(hr, writer)

      hr.instance_eval do
        date.should    ==  hr0.date
        date_0.should  ==  hr0.date_0
        date_1.should  ==  hr0.date_1
        source.should  ==  hr0.source
      end
    end
  end

  def assert_equal_rate(hr0, hr)
    tollerance = 0.00001
    hr.c1.to_s.should == hr0.c1.to_s
    hr.c2.to_s.should == hr0.c2.to_s
    hr.source.should == hr0.source
    
    hr0.rate.should be_close(hr.rate, tollerance)
    hr0.rate_avg.should be_close(hr.rate_avg, tollerance)
    hr0.rate_samples.should == hr.rate_samples.should
    
    hr0.rate_lo.should be_close(hr.rate_lo, tollerance)
    hr0.rate_hi.should be_close(hr.rate_hi, tollerance)
    hr0.rate_date_0.should be_close(hr.rate_date_0, tollerance)
    hr0.rate_date_1.should be_close(hr.rate_date_1, tollerance)
    
    hr0.date.should == hr.date
    hr0.date_0.should == hr.date_0
    hr0.date_1.should == hr.date_1
    hr0.derived.should == hr.derived
  end

  def assert_rate_defaults(hr, writer)
    hr.source.should        ==  writer.source.name
    hr.rate_avg.should      ==  hr.rate
    hr.rate_samples.should  ==  1
    hr.rate_lo.should       ==  hr.rate
    hr.rate_hi.should       ==  hr.rate
    hr.rate_date_0.should   ==  hr.rate
    hr.rate_date_1.should   ==  hr.rate
  end

end