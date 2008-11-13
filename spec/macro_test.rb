# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'test/test_base'
require 'currency'
require 'currency/macro'

module Currency

class MacroTest < TestBase
  class Record
    include ::Currency::Macro

    attr_accessor :date
    attr_accessor :gross
    attr_accessor :tax
    attr_accessor :net
    attr_accessor :currency

    attr_money :gross_money, :value => :gross, :time => :date, :currency => :currency
    attr_money :tax_money,   :value => :tax,   :time => :date, :currency => :currency
    attr_money :net_money,   :value => :net,   :time => :date, :currency => :currency

    def initialize
      self.date = Time.now
      self.currency = :USD
    end

    def compute_net
      self.net = self.gross - self.tax
    end

    def compute_net_money
      self.net_money = self.gross_money - self.tax_money
    end

  end

  def setup
    super
  end

  ############################################
  # Tests
  #

  def test_read_money
    assert_kind_of  Record, r = Record.new
    assert_not_nil  r.gross = 10.00
    assert_equal    r.gross_money.to_f, r.gross
    assert_equal    r.gross_money.currency.code, r.currency
    assert_equal    r.gross_money.time, r.date

    r
  end


  def test_write_money_rep
    assert_kind_of  Record, r = Record.new
    assert_not_nil  r.gross_money = 10.00
    assert_equal    r.gross_money.to_f, r.gross
    assert_equal    r.gross_money.currency.code, r.currency
    assert_equal    r.gross_money.time, r.date

    r
  end


  def test_money_cache
    r = test_read_money

    assert_not_nil  r_gross = r.gross
    assert          r_gross.object_id == r.gross.object_id

    # Cache flush
    assert_not_nil r.gross = 12.00
    assert_equal   r.gross_money.to_f, r.gross
    assert         r_gross.object_id != r.gross.object_id
  end


  def test_currency
    r = test_read_money

    assert_not_nil  r.gross_money.currency
    assert_equal    r.gross_money.currency.code, r.currency
    
  end


  def test_compute
    assert_kind_of  Record, r = Record.new
    assert_not_nil  r.gross = 10.00
    assert_not_nil  r.tax = 1.50
    r.compute_net

    assert_equal    8.50, r.net
    assert_equal    r.net, r.net_money.to_f

    r.compute_net_money

    assert_equal    8.50, r.net
    assert_equal    r.net, r.net_money.to_f
  end

end # class

end # module

