# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'test/ar_test_base'

require 'rubygems'
require 'active_record'
require 'active_record/migration'

require 'currency' # For :type => :money

require 'currency/exchange/rate/source/historical'
require 'currency/exchange/rate/source/historical/writer'
require 'currency/exchange/rate/source/xe'
require 'currency/exchange/rate/source/new_york_fed'


module Currency

class HistoricalWriterTest < ArTestBase

  RATE_CLASS = Exchange::Rate::Source::Historical::Rate
  TABLE_NAME = RATE_CLASS.table_name

  class HistoricalRateMigration < AR_M
    def self.up
      RATE_CLASS.__create_table(self)
    end

    def self.down
      drop_table TABLE_NAME.intern
    end
  end


  def initialize(*args)
    @currency_test_migration = HistoricalRateMigration
    super

    @src = Exchange::Rate::Source::Xe.new
    @src2 = Exchange::Rate::Source::NewYorkFed.new
  end


  def setup
    super
    
  end

  
  def test_writer
    assert_not_nil src = @src
    assert_not_nil writer = Exchange::Rate::Source::Historical::Writer.new()
    writer.time_quantitizer = :current
    writer.required_currencies = [ :USD, :GBP, :EUR, :CAD ]
    writer.base_currencies = [ :USD ]
    writer.preferred_currencies = writer.required_currencies
    writer.reciprocal_rates = true
    writer.all_rates = true
    writer.identity_rates = false
    
    writer
  end
  

  def writer_src
    writer = test_writer
    writer.source = @src
    rates = writer.write_rates
    assert_not_nil rates
    assert rates.size > 0
    assert 12, rates.size
    assert_h_rates(rates, writer)
  end


  def writer_src2
    writer = test_writer
    writer.source = @src2
    return unless writer.source.available?
    rates = writer.write_rates
    assert_not_nil rates
    assert rates.size > 0
    assert_equal 12, rates.size
    assert_h_rates(rates, writer)
  end


  def xxx_test_required_failure
    assert_not_nil writer = Exchange::Rate::Source::Historical::Writer.new()
    assert_not_nil src = @src
    writer.source = src
    writer.required_currencies = [ :USD, :GBP, :EUR, :CAD, :ZZZ ]
    writer.preferred_currencies = writer.required_currencies
    assert_raises(::RuntimeError) { writer.selected_rates }
  end


  def test_historical_rates
    # Make sure there are historical Rates avail for today.
    writer_src
    writer_src2
    
    # Force Historical Rate Source.
    source = Exchange::Rate::Source::Historical.new
    deriver = Exchange::Rate::Deriver.new(:source => source)
    Exchange::Rate::Source.default = deriver

    assert_not_nil rates = source.get_raw_rates
    assert ! rates.empty?
    # $stderr.puts "historical rates = #{rates.inspect}"

    assert_not_nil rates = source.get_rates
    assert ! rates.empty?
    # $stderr.puts "historical rates = #{rates.inspect}"
    
    assert_not_nil m_usd = ::Currency.Money('1234.56', :USD, :now)
    # $stderr.puts "m_usd = #{m_usd.to_s(:code => true)}"
    assert_not_nil m_eur = m_usd.convert(:EUR)
    # $stderr.puts "m_eur = #{m_eur.to_s(:code => true)}"

  end


  def assert_h_rates(rates, writer = nil)
    assert_not_nil hr0 = rates[0]
    rates.each do | hr |
      found_hr = nil
      begin
        assert_not_nil found_hr = hr.find_matching_this(:first)
      rescue Object => err
        raise "#{hr.inspect}: #{err}:\n#{err.backtrace.inspect}"
      end

      assert_not_nil hr0

      assert_equal hr0.date, hr.date
      assert_equal hr0.date_0, hr.date_0
      assert_equal hr0.date_1, hr.date_1
      assert_equal hr0.source, hr.source

      assert_equal_rate(hr, found_hr)
      assert_rate_defaults(hr, writer)
    end
  end


  def assert_equal_rate(hr0, hr)
    assert_equal hr0.c1.to_s, hr.c1.to_s
    assert_equal hr0.c2.to_s, hr.c2.to_s
    assert_equal hr0.source, hr.source
    assert_equal_float hr0.rate, hr.rate
    assert_equal_float hr0.rate_avg, hr.rate_avg
    assert_equal hr0.rate_samples, hr.rate_samples
    assert_equal_float hr0.rate_lo, hr.rate_lo
    assert_equal_float hr0.rate_hi, hr.rate_hi
    assert_equal_float hr0.rate_date_0, hr.rate_date_0
    assert_equal_float hr0.rate_date_1, hr.rate_date_1
    assert_equal hr0.date, hr.date
    assert_equal hr0.date_0, hr.date_0
    assert_equal hr0.date_1, hr.date_1
    assert_equal hr0.derived, hr.derived
  end


  def assert_rate_defaults(hr, writer)
    assert_equal writer.source.name, hr.source if writer
    assert_equal hr.rate, hr.rate_avg
    assert_equal hr.rate_samples, 1
    assert_equal hr.rate, hr.rate_lo
    assert_equal hr.rate, hr.rate_hi
    assert_equal hr.rate, hr.rate_date_0
    assert_equal hr.rate, hr.rate_date_1
  end


  def assert_equal_float(x1, x2, eps = 0.00001)
    eps = (x1 * eps).abs
    assert((x1 - eps) <= x2)
    assert((x1 + eps) >= x2)
  end


end

end # module

