# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

#require File.dirname(__FILE__) + '/../test_helper'

require 'test/test_base'
require 'currency/exchange/time_quantitizer'

module Currency
module Exchange

class TimeQuantitizerTest < TestBase
  def setup
    super
  end

  ############################################
  # 
  #

  def test_create
    assert_kind_of TimeQuantitizer, tq = TimeQuantitizer.new()
    assert_equal 60 * 60 * 24, tq.time_quant_size
    assert_nil tq.quantitize_time(nil)

    tq
  end


  def test_localtime
    t1 = assert_test_day(t0 = Time.new)
    assert_equal t0.utc_offset, t1.utc_offset
    assert_equal Time.now.utc_offset, t1.utc_offset
  end


  def test_utc
    t1 = assert_test_day(t0 = Time.new.utc)
    assert_equal t0.utc_offset, t1.utc_offset
  end


  def test_random
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
      assert_not_nil t1 = tq.quantitize_time(t0)
      #$stderr.puts "t0 = #{t0}"
      #$stderr.puts "t1 = #{t1}"
      
      assert_equal t0.year, t1.year
      assert_equal t0.month, t1.month
      assert_equal t0.day, t1.day
      assert_time_beginning_of_day(t1)
    rescue Object => err
      raise("#{err}\nDuring quantitize_time(#{t0} (#{t0.to_i}))")
    end

    t1
  end


  def assert_test_hour(t0)
    tq = TimeQuantitizer.new(:time_quant_size => 60 * 60) # 1 hour

    assert_not_nil t1 = tq.quantitize_time(t0)
    #$stderr.puts "t0 = #{t0}"
    #$stderr.puts "t1 = #{t1}"

    assert_equal t0.year, t1.year
    assert_equal t0.month, t1.month
    assert_equal t0.day, t1.day
    assert_time_beginning_of_hour(t1)

    t1
  end


  def assert_test_minute(t0)
    tq = TimeQuantitizer.new(:time_quant_size => 60) # 1 minute

    tq.local_timezone_offset

    assert_not_nil t1 = tq.quantitize_time(t0)
    $stderr.puts "t0 = #{t0}"
    $stderr.puts "t1 = #{t1}"

    assert_equal t0.year, t1.year
    assert_equal t0.month, t1.month
    assert_equal t0.day, t1.day
    assert_time_beginning_of_day(t1)

    t1
  end


  def assert_time_beginning_of_day(t1)
    assert_equal 0, t1.hour
    assert_time_beginning_of_hour(t1)
  end


  def assert_time_beginning_of_hour(t1)
    assert_equal 0, t1.min
    assert_time_beginning_of_min(t1)
  end


  def assert_time_beginning_of_min(t1)
    assert_equal 0, t1.sec
  end

end # class
end # module
end # module


