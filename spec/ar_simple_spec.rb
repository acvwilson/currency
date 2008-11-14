# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# Copyright (C) 2008 Asa Wilson <acvwilson(at)gmail.com>
# See LICENSE.txt for details.

require File.dirname(__FILE__) + '/ar_spec_helper'

describe Currency::ActiveRecord do
  it "simple" do
    # TODO: move insert_records into a before block?
    insert_records

    usd = @currency_test.find(@usd.id)
    usd.should_not be_nil
    assert_equal_currency usd, @usd

    cad = @currency_test.find(@cad.id)
    cad.should_not == nil
    assert_equal_money cad, @cad

    cad.amount.currency.code.should == :USD
  end
end

