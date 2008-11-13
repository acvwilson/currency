# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'test/ar_test_core'
require 'currency'

require 'rubygems'
require 'active_record'
require 'active_record/migration'
require 'currency/active_record'

module Currency

class ArFieldTest < ArTestCore

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

  def setup
    @currency_test_migration ||= CurrencyColumnTestMigration 
    @currency_test ||= CurrencyColumnTest
    super
  end

  def teardown
    super
  end

  ##################################################


  def test_field
    insert_records

    assert_not_nil usd = @currency_test.find(@usd.id)
    assert_equal_currency usd, @usd

    assert_not_nil cad = @currency_test.find(@cad.id)
    assert_equal_currency cad, @cad
  end

end

end # module

