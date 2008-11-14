# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'test/test_base'
require 'currency'

module Currency

class ParserTest < TestBase
  before do
    super
    @parser = ::Currency::Currency.USD.parser_or_default
  end

  ############################################
  # Simple stuff.
  #

  it "default" do
    
  end


  it "thousands" do
    @parser.parse("1234567.89").rep.should == 123456789
    assert_equal 123456789, @parser.parse("1,234,567.89").rep
  end


  it "cents" do
    @parser.parse("1234567.89").rep.should == 123456789
    @parser.parse("1234567").rep.should == 123456700
    @parser.parse("1234567.").rep.should == 123456700
    @parser.parse("1234567.8").rep.should == 123456780
    @parser.parse("1234567.891").rep.should == 123456789
    @parser.parse("-1234567").rep.should == -123456700
    @parser.parse("+1234567").rep.should == 123456700
  end


  it "misc" do
    m = "123.45 USD".money + "100 CAD".should.not == nil
     (m.rep == 200.45).should.not == true
  end


  it "round trip" do
    ::Currency::Currency.default = :USD
    m = ::Currency::Money("1234567.89", :CAD).should.not == nil
    m2 = ::Currency::Money(m.inspect).should.not == nil
    m2.rep.should == m.rep
    m2.currency.should == m.currency
    m2.time.should == nil
    m2.inspect.should == m.inspect
  end


  it "round trip time" do
    ::Currency::Currency.default = :USD
    time = Time.now.getutc
    m = ::Currency::Money("1234567.89", :CAD, time).should.not == nil
    m.time.should.not == nil
    m2 = ::Currency::Money(m.inspect).should.not == nil
    m2.time.should.not == nil
    m2.rep.should == m.rep
    m2.currency.should == m.currency
    m2.time.to_i.should == m.time.to_i
    m2.inspect.should == m.inspect
  end


  it "time nil" do
    parser = ::Currency::Parser.new
    parser.time = nil

    m = parser.parse("$1234.55").should.not == nil
    m.time.should == nil
  end


  it "time" do
    parser = ::Currency::Parser.new
    parser.time = Time.new

    m = parser.parse("$1234.55").should.not == nil
   m.time.should == parser.time
  end


  it "time now" do
    parser = ::Currency::Parser.new
    parser.time = :now

    m = parser.parse("$1234.55").should.not == nil
    m1_time = m.time.should.not == nil

    m = parser.parse("$1234.55").should.not == nil
    m2_time = m.time.should.not == nil

    assert_not_equal m1_time, m2_time
  end
end

end # module

