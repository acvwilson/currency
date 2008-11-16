# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/currency/exchange/rate/source/federal_reserve'

# Uncomment to avoid hitting the FED for every testrun
Currency::Exchange::Rate::Source::FederalReserve.class_eval do
  def get_page_content
    %Q{

      SPOT EXCHANGE RATE - DISNEYLAND

      ------------------------------
      14-Nov-08                          1.1
    }
  end
end

include Currency
describe "FederalReserve" do
  def available?
    unless @available
      @available = @source.available?
      STDERR.puts "Warning: FederalReserve unavailable on Saturday and Sunday, skipping tests." unless @available
    end
    @available
  end
  
  # Called by the before(:all) in spec_helper
  # Overriding here to force FederalReserve Exchange.
  # TODO: when refactoring the whole spec to test only specific FedralReserve Stuff, make sure this one goes away
  def get_rate_source(source = nil)
    @source   ||= Exchange::Rate::Source::FederalReserve.new(:verbose => false)
    @deriver  ||= Exchange::Rate::Deriver.new(:source => @source, :verbose => @source.verbose)
  end
  
  def get_rates
    @rates ||= @source.raw_rates
  end
  
  before(:all) do
    get_rate_source
    get_rates
  end
  
  before(:each) do
    get_rate_source
  end
  
  it "can retrieve rates from the FED" do
    @rates.should_not be_nil
  end

  it "can convert from USD to CAD" do
    usd = Money.new(123.45, :USD)

    cad = usd.convert(:CAD)
    cad.should_not be_nil
    cad.to_f.should be_kind_of(Numeric)
  end
  
  it "can do conversions from AUD to USD to JPY" do
    aud = Money.new(123.45, :AUD)
    usd = aud.convert(:USD)
    jpy = usd.convert(:JPY)
    jpy.should_not be_nil
    jpy.to_f.should be_kind_of(Numeric)
  end
  
end