# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'test/test_base'
require 'currency'

module Currency

class ParserTest < TestBase
  def setup
    super
    @parser = ::Currency::Currency.USD.parser_or_default
  end

  ############################################
  # Simple stuff.
  #

  def test_default
    
  end


  def test_thousands
    assert_equal 123456789, @parser.parse("1234567.89").rep
    assert_equal 123456789, @parser.parse("1,234,567.89").rep
  end


  def test_cents
    assert_equal  123456789, @parser.parse("1234567.89").rep
    assert_equal  123456700, @parser.parse("1234567").rep
    assert_equal  123456700, @parser.parse("1234567.").rep
    assert_equal  123456780, @parser.parse("1234567.8").rep
    assert_equal  123456789, @parser.parse("1234567.891").rep
    assert_equal -123456700, @parser.parse("-1234567").rep
    assert_equal  123456700, @parser.parse("+1234567").rep
  end


  def test_misc
    assert_not_nil m = "123.45 USD".money + "100 CAD"
    assert ! (m.rep == 200.45)
  end


  def test_round_trip
    ::Currency::Currency.default = :USD
    assert_not_nil m = ::Currency::Money("1234567.89", :CAD)
    assert_not_nil m2 = ::Currency::Money(m.inspect)
    assert_equal m.rep, m2.rep
    assert_equal m.currency, m2.currency
    assert_nil   m2.time
    assert_equal m.inspect, m2.inspect
  end


  def test_round_trip_time
    ::Currency::Currency.default = :USD
    time = Time.now.getutc
    assert_not_nil m = ::Currency::Money("1234567.89", :CAD, time)
    assert_not_nil m.time
    assert_not_nil m2 = ::Currency::Money(m.inspect)
    assert_not_nil m2.time
    assert_equal m.rep, m2.rep
    assert_equal m.currency, m2.currency
    assert_equal m.time.to_i, m2.time.to_i
    assert_equal m.inspect, m2.inspect
  end


  def test_time_nil
    parser = ::Currency::Parser.new
    parser.time = nil

    assert_not_nil m = parser.parse("$1234.55")
    assert_equal nil, m.time
  end


  def test_time
    parser = ::Currency::Parser.new
    parser.time = Time.new

    assert_not_nil m = parser.parse("$1234.55")
   assert_equal parser.time, m.time
  end


  def test_time_now
    parser = ::Currency::Parser.new
    parser.time = :now

    assert_not_nil m = parser.parse("$1234.55")
    assert_not_nil m1_time = m.time

    assert_not_nil m = parser.parse("$1234.55")
    assert_not_nil m2_time = m.time

    assert_not_equal m1_time, m2_time
  end
end

end # module

