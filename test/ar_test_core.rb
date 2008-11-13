# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'test/ar_test_base'

module Currency

class ArTestCore < ArTestBase

  ##################################################
  # Basic CurrenyTest AR::B class
  #

  TABLE_NAME = 'currency_test'

  class CurrencyTestMigration < AR_M
    def self.up
      create_table TABLE_NAME.intern do |t|
        t.column :name,     :string
        t.column :amount,   :integer # Money
      end
    end

    def self.down
      drop_table TABLE_NAME.intern
    end
  end


  class CurrencyTest < AR_B
    set_table_name TABLE_NAME
    attr_money :amount
  end 


  ##################################################


  def setup
    @currency_test_migration ||= CurrencyTestMigration 
    @currency_test           ||= CurrencyTest
    super
  end


  def teardown
    super
    # schema_down
  end


  ##################################################
  # 
  # 
  

  def test_insert
    insert_records
  end

end

end # module

