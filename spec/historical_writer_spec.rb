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


  before do
    super
    
  end

  
  it "writer" do
    src = @src.should.not == nil
    writer = Exchange::Rate::Source::Historical::Writer.new().should.not == nil
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
    rates.should.not == nil
    rates.size.should > 0
    12, rates.size.should.not == nil
    assert_h_rates(rates, writer)
  end


  def writer_src2
    writer = test_writer
    writer.source = @src2
    return unless writer.source.available?
    rates = writer.write_rates
    rates.should.not == nil
    rates.size.should > 0
    rates.size.should == 12
    assert_h_rates(rates, writer)
  end


  def xxx_test_required_failure
    writer = Exchange::Rate::Source::Historical::Writer.new().should.not == nil
    src = @src.should.not == nil
    writer.source = src
    writer.required_currencies = [ :USD, :GBP, :EUR, :CAD, :ZZZ ]
    writer.preferred_currencies = writer.required_currencies
    assert_raises(::RuntimeError) { writer.selected_rates }
  end


  it "historical rates" do
    # Make sure there are historical Rates avail for today.
    writer_src
    writer_src2
    
    # Force Historical Rate Source.
    source = Exchange::Rate::Source::Historical.new
    deriver = Exchange::Rate::Deriver.new(:source => source)
    Exchange::Rate::Source.default = deriver

    rates = source.get_raw_rates.should.not == nil
     rates.empty?.should.not == true
    # $stderr.puts "historical rates = #{rates.inspect}"

    rates = source.get_rates.should.not == nil
     rates.empty?.should.not == true
    # $stderr.puts "historical rates = #{rates.inspect}"
    
    m_usd = ::Currency.Money('1234.56', :USD, :now).should.not == nil
    # $stderr.puts "m_usd = #{m_usd.to_s(:code => true)}"
    m_eur = m_usd.convert(:EUR).should.not == nil
    # $stderr.puts "m_eur = #{m_eur.to_s(:code => true)}"

  end


  def assert_h_rates(rates, writer = nil)
    hr0 = rates[0].should.not == nil
    rates.each do | hr |
      found_hr = nil
      begin
        found_hr = hr.find_matching_this(:first).should.not == nil
      rescue Object => err
        raise "#{hr.inspect}: #{err}:\n#{err.backtrace.inspect}"
      end

      hr0.should.not == nil

      hr.date.should == hr0.date
      hr.date_0.should == hr0.date_0
      hr.date_1.should == hr0.date_1
      hr.source.should == hr0.source

      assert_equal_rate(hr, found_hr)
      assert_rate_defaults(hr, writer)
    end
  end


  def assert_equal_rate(hr0, hr)
    hr.c1.to_s.should == hr0.c1.to_s
    hr.c2.to_s.should == hr0.c2.to_s
    hr.source.should == hr0.source
    assert_equal_float hr0.rate, hr.rate
    assert_equal_float hr0.rate_avg, hr.rate_avg
    hr.rate_samples.should == hr0.rate_samples
    assert_equal_float hr0.rate_lo, hr.rate_lo
    assert_equal_float hr0.rate_hi, hr.rate_hi
    assert_equal_float hr0.rate_date_0, hr.rate_date_0
    assert_equal_float hr0.rate_date_1, hr.rate_date_1
    hr.date.should == hr0.date
    hr.date_0.should == hr0.date_0
    hr.date_1.should == hr0.date_1
    hr.derived.should == hr0.derived
  end


  def assert_rate_defaults(hr, writer)
    hr.source if writer.should == writer.source.name
    hr.rate_avg.should == hr.rate
    1.should == hr.rate_samples
    hr.rate_lo.should == hr.rate
    hr.rate_hi.should == hr.rate
    hr.rate_date_0.should == hr.rate
    hr.rate_date_1.should == hr.rate
  end


  def assert_equal_float(x1, x2, eps = 0.00001)
    eps = (x1 * eps).abs
    assert((x1 - eps) <= x2)
    assert((x1 + eps) >= x2)
  end


end

end # module

