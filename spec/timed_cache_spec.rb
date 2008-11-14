# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'test/test_base'

require 'currency'
require 'currency/exchange/rate/source/xe'
require 'currency/exchange/rate/source/timed_cache'

module Currency

class TimedCacheTest < TestBase
  before do
    super
  end


  def get_rate_source
    @source = source = Exchange::Rate::Source::Xe.new

    # source.verbose = true
    deriver = Exchange::Rate::Deriver.new(:source => source)

    @cache = cache = Exchange::Rate::Source::TimedCache.new(:source => deriver)
    
    cache
  end


  it "timed cache usd cad" do
    rates = @source.raw_rates.should_not == nil
    rates[:USD].should_not == nil
    usd_cad = rates[:USD][:CAD].should_not == nil

    usd = Money.new(123.45, :USD).should_not == nil
    cad = usd.convert(:CAD).should_not == nil

    assert_kind_of Numeric, m = (cad.to_f / usd.to_f)
    # $stderr.puts "m = #{m}"
    assert_equal_float usd_cad, m, 0.001
  end


  it "timed cache cad eur" do
    rates = @source.raw_rates.should_not == nil
    rates[:USD].should_not == nil
    usd_cad = rates[:USD][:CAD].should_not == nil
    usd_eur = rates[:USD][:EUR].should_not == nil

    cad = Money.new(123.45, :CAD).should_not == nil
    eur = cad.convert(:EUR).should_not == nil

    assert_kind_of Numeric, m = (eur.to_f / cad.to_f)
    # $stderr.puts "m = #{m}"
    assert_equal_float((1.0 / usd_cad) * usd_eur, m, 0.001)
  end


  it "reload" do
    # @cache.verbose = 5

    test_timed_cache_cad_eur

    rates = @source.raw_rates.should_not == nil
    rates[:USD].should_not == nil
    usd_cad_1 = rates[:USD][:CAD].should_not == nil

    t1 = @cache.rate_load_time.should_not == nil
    t1_reload = @cache.rate_reload_time.should_not == nil
    t1_reload.to_i.should > t1.to_i

    @cache.time_to_live = 5
    @cache.time_to_live_fudge = 0

    # puts @cache.rate_reload_time.to_i - @cache.rate_load_time.to_i
    @cache.rate_reload_time.to_i - @cache.rate_load_time.to_i == @cache.time_to_live.should_not == nil

    sleep 10

    test_timed_cache_cad_eur
    
    t2 = @cache.rate_load_time.should_not == nil
    t1.to_i != t2.to_i.should_not == nil

    rates = @source.raw_rates.should_not == nil
    rates[:USD].should_not == nil
    usd_cad_2 = rates[:USD][:CAD].should_not == nil

    usd_cad_1.object_id != usd_cad_2.object_id.should_not == nil
  end

end

end # module

