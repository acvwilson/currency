require File.dirname(__FILE__) + '/ar_spec_helper'


##################################################
# Basic CurrenyTest AR::B class
#

# TODO: Move elsewhere, combine with other AR tests

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

describe "ActiveRecord macros" do
  before(:all) do
    AR_B.establish_connection(database_spec)
    @currency_test_migration ||= CurrencyColumnTestMigration 
    @currency_test ||= CurrencyColumnTest
    schema_down
    schema_up
  end
  
  after(:all) do
    schema_down
  end

  it "can store and retrieve money values from a DB and automagically transfomr them to Money" do
    insert_records

    usd = @currency_test.find(@usd.id)
    usd.should == @usd
    usd.object_id.should_not == @usd.object_id # not same object

    cad = @currency_test.find(@cad.id)
    cad.should == @cad
    cad.object_id.should_not == @cad.object_id # not same object
  end
end
