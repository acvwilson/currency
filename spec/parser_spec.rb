# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.
require File.dirname(__FILE__) + '/spec_helper'

describe Currency::Parser do
  before do
    @parser = ::Currency::Currency.USD.parser_or_default
  end

  describe "is great at parsing strings" do
    it "can use a string that uses the thousands-separator (comma)" do
      @parser.parse("1234567.89").rep.should == 123456789
      @parser.parse("1,234,567.89").rep.should == 123456789
    end


    it "parses cents" do
      @parser.parse("1234567.89").rep.should == 123456789
      @parser.parse("1234567").rep.should == 123456700
      @parser.parse("1234567.").rep.should == 123456700
      @parser.parse("1234567.8").rep.should == 123456780
      @parser.parse("1234567.891").rep.should == 123456789
      @parser.parse("-1234567").rep.should == -123456700
      @parser.parse("+1234567").rep.should == 123456700
    end
  end

  describe "can convert the right hand side argument" do
    it "converts the right hand argument to the left hand side currency if needed" do
      m = "123.45 USD".money + "100 CAD"
      m.should_not == nil
      m.rep.should == ("123.45".money(:USD) + "100 CAD".money(:USD)).rep
    end

    it "uses the left hand sides currency if the right hand side argument does provide currency info" do
      m = "123.45 USD".money
      (m + 100).rep.should == (m + "100".money(:USD)).rep
    end
  end

  describe "can use the inspect method as a serialization of self" do
    it "can recreate a money object by using a .inspect-string" do
      ::Currency::Currency.default = :USD
      m = ::Currency::Money("1234567.89", :CAD)
      m2 = ::Currency::Money(m.inspect)

      m2.rep.should == m.rep
      m2.currency.should == m.currency

      m2.inspect.should == m.inspect
    end


    it "can recreate a money objectby using a .inspect-string and keep the time parameter as well" do
      ::Currency::Currency.default = :USD
      time = Time.now.getutc
      m = ::Currency::Money("1234567.89", :CAD, time)
      m.time.should_not == nil

      m2 = ::Currency::Money(m.inspect)
      m2.time.should_not == nil

      m.should_not be(m2)

      m2.rep.should == m.rep
      m2.currency.should == m.currency
      m2.time.to_i.should == m.time.to_i
      m2.inspect.should == m.inspect
    end
  end

  describe "deals with time when creating money objects" do
    before do
      @parser = ::Currency::Parser.new
    end
    
    it "can parse even though the parser time is nil" do
      @parser.time = nil

      m = @parser.parse("$1234.55")
      m.time.should == nil
    end


    it "parses money strings into money object using the parsers time" do
      @parser.time = Time.now

      m = @parser.parse("$1234.55")
      m.time.should == @parser.time
    end


    it "when re-initializing a money object, the time is also re-initialized" do
      @parser.time = :now

      m = @parser.parse("$1234.55")
      m1_time = m.time

      m = @parser.parse("$1234.55")
      m2_time = m.time

      m1_time.should_not == m2_time
    end
  end
end
