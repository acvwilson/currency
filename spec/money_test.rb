# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.


require 'test/test_base'
require 'currency'

module Currency

class MoneyTest < TestBase
  def setup
    super
  end

  ############################################
  # Simple stuff.
  #

  def test_create
    assert_kind_of Money, m = Money.new(1.99)
    assert_equal m.currency, Currency.default
    assert_equal m.currency.code, :USD

    m
  end

  def test_object_money_method
    assert_kind_of Money, m = 1.99.money(:USD)
    assert_equal m.currency.code, :USD
    assert_equal m.rep, 199

    assert_kind_of Money, m = 199.money(:CAD)
    assert_equal m.currency.code, :CAD
    assert_equal m.rep, 19900

    assert_kind_of Money, m = "13.98".money(:CAD)
    assert_equal m.currency.code, :CAD
    assert_equal m.rep, 1398

    assert_kind_of Money, m = "45.99".money(:EUR)
    assert_equal m.currency.code, :EUR
    assert_equal m.rep, 4599
  end

  def test_zero
    m = Money.new(0)
    assert ! m.negative?
    assert   m.zero?
    assert ! m.positive?
    m
  end

  def test_negative
    m = Money.new(-1.00, :USD)
    assert   m.negative?
    assert ! m.zero?
    assert ! m.positive?
    m
  end

  def test_positive
    m = Money.new(2.99, :USD)
    assert ! m.negative?
    assert ! m.zero?
    assert   m.positive?
    m
  end

  def test_relational
    n = test_negative
    z = test_zero
    p = test_positive

    assert   (n < p)
    assert ! (n > p)
    assert ! (p < n)
    assert   (p > n)
    assert   (p != n)

    assert   (z <= z)
    assert   (z >= z)

    assert   (z <= p)
    assert   (n <= z)
    assert   (z >= n)

    assert   n == n
    assert   p == p

    assert   z == test_zero
  end

  def test_compare
    n = test_negative
    z = test_zero
    p = test_positive

    assert (n <=> p) == -1
    assert (p <=> n) == 1
    assert (p <=> z) == 1

    assert (n <=> n) == 0
    assert (z <=> z) == 0
    assert (p <=> p) == 0    
  end

  def test_rep
    assert_not_nil m = Money.new(123, :USD)
    assert  m.rep == 12300
    
    assert_not_nil m = Money.new(123.45, :USD)
    assert  m.rep == 12345

    assert_not_nil m = Money.new("123.456", :USD)
    assert  m.rep == 12345
  end

  def test_convert
    assert_not_nil m = Money.new("123.456", :USD)
    assert  m.rep == 12345

    assert_equal 123, m.to_i
    assert_equal 123.45, m.to_f
    assert_equal "$123.45", m.to_s
  end

  def test_eql
    assert_not_nil usd1 = Money.new(123, :USD)
    assert_not_nil usd2 = Money.new("123", :USD)

    assert_equal :USD, usd1.currency.code
    assert_equal :USD, usd2.currency.code
    
    assert_equal usd1.rep, usd2.rep

    assert usd1 == usd2

  end

  def test_not_eql  
 
    assert_not_nil usd1 = Money.new(123, :USD)
    assert_not_nil usd2 = Money.new("123.01", :USD)

    assert_equal :USD, usd1.currency.code
    assert_equal :USD, usd2.currency.code
    
    assert_not_equal usd1.rep, usd2.rep

    assert usd1 != usd2

    ################
    # currency !=
    # rep ==

    assert_not_nil usd = Money.new(123, :USD)
    assert_not_nil cad = Money.new(123, :CAD)

    assert_equal :USD, usd.currency.code
    assert_equal :CAD, cad.currency.code

    assert_equal usd.rep, cad.rep
    assert usd.currency != cad.currency

    assert usd != cad

  end

  def test_op
    # Using default get_rate
    assert_not_nil usd = Money.new(123.45, :USD)
    assert_not_nil cad = Money.new(123.45, :CAD)

    # - Money => Money
    assert_equal(-12345, (- usd).rep)
    assert_equal :USD, (- usd).currency.code

    assert_equal(-12345, (- cad).rep)
    assert_equal :CAD, (- cad).currency.code

    # Money + Money => Money
    assert_kind_of Money, m = (usd + usd)
    assert_equal 24690, m.rep
    assert_equal :USD, m.currency.code

    assert_kind_of Money, m = (usd + cad)
    assert_equal 22889, m.rep
    assert_equal :USD, m.currency.code

    assert_kind_of Money, m = (cad + usd)
    assert_equal 26798, m.rep
    assert_equal :CAD, m.currency.code

    # Money - Money => Money
    assert_kind_of Money, m = (usd - usd)
    assert_equal 0, m.rep
    assert_equal :USD, m.currency.code

    assert_kind_of Money, m = (usd - cad)
    assert_equal 1801, m.rep
    assert_equal :USD, m.currency.code

    assert_kind_of Money, m = (cad - usd)
    assert_equal -2108, m.rep
    assert_equal :CAD, m.currency.code

    # Money * Numeric => Money
    assert_kind_of Money, m = (usd * 0.5)
    assert_equal 6172, m.rep
    assert_equal :USD, m.currency.code

    # Money / Numeric => Money
    assert_kind_of Money, m = usd / 3
    assert_equal 4115, m.rep
    assert_equal :USD, m.currency.code

    # Money / Money => Numeric
    assert_kind_of Numeric, m = usd / Money.new("41.15", :USD)
    assert_equal_float 3.0, m
    
    assert_kind_of Numeric, m = (usd / cad)
    assert_equal_float Exchange::Rate::Source::Test.USD_CAD, m, 0.0001
  end


  def test_pivot_conversions
    # Using default get_rate
    assert_not_nil cad = Money.new(123.45, :CAD)
    assert_not_nil eur = cad.convert(:EUR)
    assert_kind_of Numeric, m = (eur.to_f / cad.to_f)
    m_expected = (1.0 / Exchange::Rate::Source::Test.USD_CAD) * Exchange::Rate::Source::Test.USD_EUR
    # $stderr.puts "m = #{m}, expected = #{m_expected}"
    assert_equal_float m_expected, m, 0.001


    assert_not_nil gbp = Money.new(123.45, :GBP)
    assert_not_nil eur = gbp.convert(:EUR)
    assert_kind_of Numeric, m = (eur.to_f / gbp.to_f)
    m_expected = (1.0 / Exchange::Rate::Source::Test.USD_GBP) * Exchange::Rate::Source::Test.USD_EUR
    # $stderr.puts "m = #{m}, expected = #{m_expected}"
    assert_equal_float m_expected, m, 0.001
  end


  def test_invalid_currency_code
    assert_raise Exception::InvalidCurrencyCode do
      Money.new(123, :asdf)
    end
    assert_raise Exception::InvalidCurrencyCode do
      Money.new(123, 5)
    end
  end


  def test_time_default
    Money.default_time = nil

    assert_not_nil usd = Money.new(123.45, :USD)
    assert_nil usd.time

    Money.default_time = Time.now
    assert_not_nil usd = Money.new(123.45, :USD)
    assert_equal usd.time, Money.default_time
  end


  def test_time_now
    # Test
    Money.default_time = :now

    assert_not_nil usd = Money.new(123.45, :USD)
    assert_not_nil usd.time

    sleep 1

    assert_not_nil usd2 = Money.new(123.45, :USD)
    assert_not_nil usd2.time
    assert usd.time != usd2.time

    Money.default_time = nil
  end


  def test_time_fixed
    # Test for fixed time.
    Money.default_time = Time.new

    assert_not_nil usd = Money.new(123.45, :USD)
    assert_not_nil usd.time

    sleep 1

    assert_not_nil usd2 = Money.new(123.45, :USD)
    assert_not_nil usd2.time
    assert usd.time == usd2.time
  end

end # class

end # module

