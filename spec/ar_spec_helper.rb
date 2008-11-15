# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# Copyright (C) 2008 Asa Wilson <acvwilson(at)gmail.com>
# See LICENSE.txt for details.

require File.dirname(__FILE__) + '/spec_helper'

require 'active_record'
require 'active_record/migration'
require File.dirname(__FILE__) + '/../lib/currency/active_record'

AR_M = ActiveRecord::Migration
AR_B = ActiveRecord::Base

def ar_setup
  AR_B.establish_connection(database_spec)

  # Subclasses can override this.
  @currency_test_migration ||= nil
  @currency_test ||= nil

  # schema_down

  schema_up
  
end

# DB Connection info
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

  # @database_spec = {
  #   :adapter  => ENV['TEST_DB_ADAPTER'] || 'mysql',
  #   :host     => ENV['TEST_DB_HOST']    || 'localhost',
  #   :username => ENV['TEST_DB_USER']    || 'test',
  #   :password => ENV['TEST_DB_PASS']    || 'test',
  #   :database => ENV['TEST_DB_TEST']    || 'test'
  # }
  
  @database_spec = {
    :adapter  => ENV['TEST_DB_ADAPTER'] || 'mysql',
    :host     => ENV['TEST_DB_HOST']    || 'localhost',
    :username => ENV['TEST_DB_USER']    || 'root',
    :password => ENV['TEST_DB_PASS']    || '',
    :database => ENV['TEST_DB_TEST']    || 'currency_gem_test'
  }
  
end

# Run AR migrations UP
def schema_up
  return unless @currency_test_migration
  begin
    @currency_test_migration.migrate(:up)
  rescue Object =>e
    $stderr.puts "Warning: #{e}"
  end
end


# Run AR migrations DOWN
def schema_down
  return unless @currency_test_migration
  begin
    @currency_test_migration.migrate(:down)
  rescue Object => e
    $stderr.puts "Warning: #{e}"
  end
end

# Scaffold: insert stuff into DB so we can test AR integration
def insert_records
  delete_records

  @currency_test.reset_column_information

  @usd = @currency_test.new(:name => '#1: USD', :amount => Currency::Money.new("12.34", :USD))
  @usd.save

  @cad = @currency_test.new(:name => '#2: CAD', :amount => Currency::Money.new("56.78", :CAD))
  @cad.save
end

def delete_records
  @currency_test.destroy_all
end

##################################################

# TODO: need this?
def assert_equal_money(a,b)
  a.should_not be_nil
  b.should_not be_nil
  # Make sure a and b are not the same object.
  b.object_id.should_not == a.object_id
  b.id.should == a.id
  a.amount.should_not == nil
  a.amount.should be_kind_of(Currency::Money) 
  b.amount.should_not == nil
  b.amount.should be_kind_of(Currency::Money) 
  # Make sure that what gets stored in the database comes back out
  # when converted back to the original currency.
  b.amount.rep.should == a.amount.convert(b.amount.currency).rep
end

# TODO: need this?
def assert_equal_currency(a,b)
  assert_equal_money a, b

  b.amount.rep.should == a.amount.rep
  b.amount.currency.should == a.amount.currency
  b.amount.currency.code.should == a.amount.currency.code

end