# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

# require 'test/ar_test_core'
# require 'currency'
# 
# require 'rubygems'
# require 'active_record'
# require 'active_record/migration'
# require 'currency/active_record'

require File.dirname(__FILE__) + '/ar_spec_helper'

# module Currency
# 
# class ArFieldTest < ArTestCore

  ##################################################
  # Basic CurrenyTest AR::B class
  #

  TABLE_NAME = 'currency_column_test'

  class CurrencyColumnTestMigration < AR_M
    def self.up
      create_table TABLE_NAME.intern do |t|
        t.column :name,     :string
        t.column :amount,   :integer # Money
        t.column :amount_currency,   :string, :size => 3 # Money.currency.code
      end
    end

    def self.down
      drop_table TABLE_NAME.intern
    end
  end

  class CurrencyColumnTest < AR_B
    set_table_name TABLE_NAME
    attr_money :amount, :currency_column => true
  end 

  ##################################################


  # def teardown
  #   super
  # end

  ##################################################

describe "ActiveRecord macros" do
  before(:all) do
    AR_B.establish_connection(database_spec)
    @currency_test_migration ||= CurrencyColumnTestMigration 
    @currency_test ||= CurrencyColumnTest
    # schema_down
    schema_up
  end
  
  after(:all) do
    # schema_down
  end

  it "field" do
    insert_records

    usd = @currency_test.find(@usd.id)
    usd.should_not be_nil
    assert_equal_currency usd, @usd

    cad = @currency_test.find(@cad.id)
    cad.should_not be_nil
    assert_equal_currency cad, @cad
  end
end
