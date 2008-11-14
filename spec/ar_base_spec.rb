# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'test/test_base'
require 'currency'

require 'rubygems'
require 'active_record'
require 'active_record/migration'
require 'currency/active_record'

AR_M = ActiveRecord::Migration
AR_B = ActiveRecord::Base

module Currency

class ArTestBase < TestBase

  ##################################################

  before do
    super
    AR_B.establish_connection(database_spec)

    # Subclasses can override this.
    @currency_test_migration ||= nil
    @currency_test ||= nil

    # schema_down

    schema_up
  end


  def teardown
    super
    # schema_down
  end


  def database_spec
    # TODO: Get from ../config/database.yml:test
    # Create test database on:

    # MYSQL:
    #
    # sudo mysqladmin create test;
    # sudo mysql
    # grant all on test.* to test@localhost identified by 'test';
    # flush privileges;

    # POSTGRES:
    #
    # CREATE USER test PASSWORD 'test';
    # CREATE DATABASE test WITH OWNER = test;
    #

    @database_spec = {
      :adapter  => ENV['TEST_DB_ADAPTER'] || 'mysql',
      :host     => ENV['TEST_DB_HOST']    || 'localhost',
      :username => ENV['TEST_DB_USER']    || 'test',
      :password => ENV['TEST_DB_PASS']    || 'test',
      :database => ENV['TEST_DB_TEST']    || 'test'
    }
  end


  def schema_up
    return unless @currency_test_migration
    begin
      @currency_test_migration.migrate(:up)
    rescue Object =>e
      $stderr.puts "Warning: #{e}"
    end
  end


  def schema_down
    return unless @currency_test_migration
    begin
      @currency_test_migration.migrate(:down)
    rescue Object => e
      $stderr.puts "Warning: #{e}"
    end
  end


  ##################################################
  # Scaffold
  # 

  def insert_records
    delete_records

    @currency_test.reset_column_information

    @usd = @currency_test.new(:name => '#1: USD', :amount => Money.new("12.34", :USD))
    @usd.save

    @cad = @currency_test.new(:name => '#2: CAD', :amount => Money.new("56.78", :CAD))
    @cad.save
  end


  def delete_records
    @currency_test.destroy_all
  end


  ##################################################


  def assert_equal_money(a,b)
    a.should_not be_nil
    b.should_not be_nil
    # Make sure a and b are not the same object.
    b.object_id.should_not == a.object_id
    b.id.should == a.id
    a.amount.should.not == nil
    a.amount.should be_kind_of(Money) 
    b.amount.should.not == nil
    b.amount.should be_kind_of(Money) 
    # Make sure that what gets stored in the database comes back out
    # when converted back to the original currency.
    b.amount.rep.should == a.amount.convert(b.amount.currency).rep
  end


  def assert_equal_currency(a,b)
    assert_equal_money a, b

    b.amount.rep.should == a.amount.rep
    b.amount.currency.should == a.amount.currency
    b.amount.currency.code.should == a.amount.currency.code

  end
end

end # module

