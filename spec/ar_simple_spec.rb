# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'test/ar_test_core'
require 'currency'

require 'rubygems'
require 'active_record'
require 'active_record/migration'
require 'currency/active_record'

module Currency

class ArSimpleTest < ArTestCore

  it "simple" do
    insert_records

    usd = @currency_test.find(@usd.id).should.not == nil
    assert_equal_currency usd, @usd

    cad = @currency_test.find(@cad.id).should.not == nil
    assert_equal_money cad, @cad

    :USD.should == cad.amount.currency.code
  end

end

end # module

