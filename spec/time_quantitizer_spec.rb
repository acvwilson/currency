# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

#require File.dirname(__FILE__) + '/../test_helper'

require 'test/test_base'
require 'currency/exchange/time_quantitizer'

module Currency
module Exchange

class TimeQuantitizerTest < TestBase
  before do
    super
  end

  ############################################
  # 
  #

  it "create" do
    assert_kind_of TimeQuantitizer, tq = TimeQuantitizer.new()
    tq.time_quant_size.should == 60 * 60 * 24
    tq.quantitize_time(nil).should == nil

    tq
  end


  it "localtime" do
    t1 = assert_test_day(t0 = Time.new)
    t1.utc_offset.should == t0.utc_offset
    t1.utc_offset.should == Time.now.utc_offset
  end


  it "utc" do
    t1 = assert_test_day(t0 = Time.new.utc)
    t1.utc_offset.should == t0.utc_offset
  end


  it "random" do
    (1 .. 1000).each do
      t0 = Time.at(rand(1234567901).to_i)
      assert_test_day(t0)
      assert_test_hour(t0)
      # Problem year?
      t0 = Time.parse('1977/01/01') + rand(60 * 60 * 24 * 7 * 52).to_i
      assert_test_day(t0)
      assert_test_hour(t0)
      # Problem year?
      t0 = Time.parse('1995/01/01') + rand(60 * 60 * 24 * 7 * 52).to_i
      assert_test_day(t0)
      assert_test_hour(t0)     
    end

   
  end


  def assert_test_day(t0)
    tq = test_create

    begin
      t1 = tq.quantitize_time(t0).should.not == nil
      #$stderr.puts "t0 = #{t0}"
      #$stderr.puts "t1 = #{t1}"
      
      t1.year.should == t0.year
      t1.month.should == t0.month
      t1.day.should == t0.day
      assert_time_beginning_of_day(t1)
    rescue Object => err
      raise("#{err}\nDuring quantitize_time(#{t0} (#{t0.to_i}))")
    end

    t1
  end


  def assert_test_hour(t0)
    tq = TimeQuantitizer.new(:time_quant_size => 60 * 60) # 1 hour

    t1 = tq.quantitize_time(t0).should.not == nil
    #$stderr.puts "t0 = #{t0}"
    #$stderr.puts "t1 = #{t1}"

    t1.year.should == t0.year
    t1.month.should == t0.month
    t1.day.should == t0.day
    assert_time_beginning_of_hour(t1)

    t1
  end


  def assert_test_minute(t0)
    tq = TimeQuantitizer.new(:time_quant_size => 60) # 1 minute

    tq.local_timezone_offset

    t1 = tq.quantitize_time(t0).should.not == nil
    $stderr.puts "t0 = #{t0}"
    $stderr.puts "t1 = #{t1}"

    t1.year.should == t0.year
    t1.month.should == t0.month
    t1.day.should == t0.day
    assert_time_beginning_of_day(t1)

    t1
  end


  def assert_time_beginning_of_day(t1)
    t1.hour.should == 0
    assert_time_beginning_of_hour(t1)
  end


  def assert_time_beginning_of_hour(t1)
    t1.min.should == 0
    assert_time_beginning_of_min(t1)
  end


  def assert_time_beginning_of_min(t1)
    t1.sec.should == 0
  end

end # class
end # module
end # module


