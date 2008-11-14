require File.dirname(__FILE__) + '/spec_helper'

describe Currency::Formatter do
  before(:each) do
    @time = nil
    @money = Currency::Money.new_rep(12345678900, :USD, @time)
    
  end

  it "can convert to string" do
    @money.should be_kind_of(Currency::Money) 
    @money.currency.should == Currency::Currency.default
    @money.currency.code.should == :USD
    @money.to_s.should == "$1,234,567.8900"
    @money.time.should == @time
  end


  it "handles thousands options" do
    @money.to_s(:thousands => false).should == "$1234567.8900"
    @money.to_s(:thousands => true).should == "$1,234,567.8900"
  end


  it "handles cents options" do
    @money.to_s(:cents => false).should == "$1,234,567"
    @money.to_s(:cents => true).should == "$1,234,567.8900"
  end


  it "handles symbol options" do
    @money.to_s(:symbol => false).should == "1,234,567.8900"
    @money.to_s(:symbol => true).should == "$1,234,567.8900"
  end


  it "handles code options" do
    @money.to_s(:code => false).should == "$1,234,567.8900"
    @money.to_s(:code => true).should == "USD $1,234,567.8900"
  end


  it "handles html and more" do
    m = ::Currency::Money(12.45, :USD)
    money_string = m.to_s(:html => true, :code => true)
    money_string.should == "<span class=\"currency_code\">USD</span> $12.4500"
    

    m = ::Currency::Money(12.45, :EUR)
    money_string = m.to_s(:html => true, :code => true)
    money_string.should == "<span class=\"currency_code\">EUR</span> &#8364;12.4500"

    m = ::Currency::Money(12345.45, :EUR)
    money_string = m.to_s(:html => true, :code => true, :thousands_separator => '_')
    money_string.should == "<span class=\"currency_code\">EUR</span> &#8364;12_345.4500"
  end


  it "handles time options" do
    time = Time.new
    m = Currency::Money.new_rep(12345678900, :USD, time)
    m.to_s(:time => false).should == "$1,234,567.8900"
    m.to_s(:time => true).should == "$1,234,567.8900 #{time.getutc.xmlschema(4)}"
  end

  it "handles decimal options" do
    @money = Currency::Money.new_rep(12345678900, :USD, @time)
    @money.to_s(:decimals => 2).should == "$1,234,567.89"
    @money.to_s(:decimals => 3).should == "$1,234,567.890"
    @money.to_s(:decimals => 4).should == "$1,234,567.8900"
  end
end
