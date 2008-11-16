# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/currency/exchange/rate/source/federal_reserve'

# Uncomment to avoid hitting the FED for every testrun
# Currency::Exchange::Rate::Source::FederalReserve.class_eval do
#   def get_page_content
#     %Q{
# 
#       SPOT EXCHANGE RATE - DISNEYLAND
# 
#       ------------------------------
#       14-Nov-08                          1.1
#     }
#   end
# end

include Currency
describe "FederalReserve" do
  def available?
    unless @available
      @available = @source.available?
      STDERR.puts "Warning: FederalReserve unavailable on Saturday and Sunday, skipping tests." unless @available
    end
    @available
  end
  
  # Force FederalReserve Exchange.
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
    # cad.should_not be_nil
    # cad.to_f.should be_kind_of(Numeric)
  end
  
  it "can convert CAD to EUR" do
    aud = Money.new(123.45, :AUD)
    usd = aud.convert(:USD)
    jpy = usd.convert(:JPY)
    
    # eur = cad.convert(:EUR)
    # eur.should_not be_nil
    # eur.to_f.should be_kind_of(Numeric)
    # eur.rep.should > 0
  end
  
end

# class FederalReserveTest < TestBase
#   before do
#     super
#   end
# 
# 
#   @@available = nil
# 
#   # New York Fed rates are not available on Saturday and Sunday.
#   def available?
#     if @@available == nil
#       @@available = @source.available?
#       STDERR.puts "Warning: FederalReserve unavailable on Saturday and Sunday, skipping tests." unless @@available
#     end
#     @@available
#   end
# 
# 
#   def get_rate_source
#     # Force FederalReserve Exchange.
#     verbose = false
#     source = @source = Exchange::Rate::Source::FederalReserve.new(:verbose => verbose)
#     deriver = Exchange::Rate::Deriver.new(:source => source, :verbose => source.verbose)
#   end
# 
# 
# 
#   it "usd cad" do
#     return unless available?
# 
#     # yesterday = Time.now.to_date - 1
# 
#     rates = Exchange::Rate::Source.default.source.raw_rates.should_not == nil
#     #assert_not_nil rates[:USD]
#     #assert_not_nil usd_cad = rates[:USD][:CAD]
# 
#     usd = Money.new(123.45, :USD).should_not == nil
#     cad = usd.convert(:CAD).should_not == nil
# 
#     # assert_kind_of Numeric, m = (cad.to_f / usd.to_f)
#     # $stderr.puts "m = #{m}"
#     # assert_equal_float usd_cad, m, 0.001
#   end
# 
# 
#   it "cad eur" do
#     return unless available?
# 
#     rates = Exchange::Rate::Source.default.source.raw_rates.should_not == nil
#     #assert_not_nil rates[:USD]
#     #assert_not_nil usd_cad = rates[:USD][:CAD]
#     #assert_not_nil usd_eur = rates[:USD][:EUR]
# 
#     cad = Money.new(123.45, :CAD).should_not == nil
#     eur = cad.convert(:EUR).should_not == nil
# 
#     #assert_kind_of Numeric, m = (eur.to_f / cad.to_f)
#     # $stderr.puts "m = #{m}"
#     #assert_equal_float (1.0 / usd_cad) * usd_eur, m, 0.001
#   end
# 
# end
# 
# end # module
# 
