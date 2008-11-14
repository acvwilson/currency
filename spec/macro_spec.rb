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

  before do
    super
  end

  ############################################
  # Tests
  #

  it "read money" do
    assert_kind_of  Record, r = Record.new
    r.gross = 10.00.should_not == nil
    r.gross.should == r.gross_money.to_f
    r.currency.should == r.gross_money.currency.code
    r.date.should == r.gross_money.time

    r
  end


  it "write money rep" do
    assert_kind_of  Record, r = Record.new
    r.gross_money = 10.00.should_not == nil
    r.gross.should == r.gross_money.to_f
    r.currency.should == r.gross_money.currency.code
    r.date.should == r.gross_money.time

    r
  end


  it "money cache" do
    r = test_read_money

    r_gross = r.gross.should_not == nil
    r_gross.object_id.should == r.gross.object_id

    # Cache flush
    r.gross = 12.00.should_not == nil
    r.gross.should == r.gross_money.to_f
    r_gross.object_id != r.gross.object_id.should_not == nil
  end


  it "currency" do
    r = test_read_money

    r.gross_money.currency.should_not == nil
    r.currency.should == r.gross_money.currency.code
    
  end


  it "compute" do
    assert_kind_of  Record, r = Record.new
    r.gross = 10.00.should_not == nil
    r.tax = 1.50.should_not == nil
    r.compute_net

    r.net.should == 8.50
    r.net_money.to_f.should == r.net

    r.compute_net_money

    r.net.should == 8.50
    r.net_money.to_f.should == r.net
  end

end # class

end # module

