# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'test/test_base'

require 'currency'
require 'currency/exchange/rate/source/xe'
require 'currency/exchange/rate/source/timed_cache'

module Currency

class TimedCacheTest < TestBase
  def setup
    super
  end


  def get_rate_source
    @source = source = Exchange::Rate::Source::Xe.new

    # source.verbose = true
    deriver = Exchange::Rate::Deriver.new(:source => source)

    @cache = cache = Exchange::Rate::Source::TimedCache.new(:source => deriver)
    
    cache
  end


  def test_timed_cache_usd_cad
    assert_not_nil rates = @source.raw_rates
    assert_not_nil rates[:USD]
    assert_not_nil usd_cad = rates[:USD][:CAD]

    assert_not_nil usd = Money.new(123.45, :USD)
    assert_not_nil cad = usd.convert(:CAD)

    assert_kind_of Numeric, m = (cad.to_f / usd.to_f)
    # $stderr.puts "m = #{m}"
    assert_equal_float usd_cad, m, 0.001
  end


  def test_timed_cache_cad_eur
    assert_not_nil rates = @source.raw_rates
    assert_not_nil rates[:USD]
    assert_not_nil usd_cad = rates[:USD][:CAD]
    assert_not_nil usd_eur = rates[:USD][:EUR]

    assert_not_nil cad = Money.new(123.45, :CAD)
    assert_not_nil eur = cad.convert(:EUR)

    assert_kind_of Numeric, m = (eur.to_f / cad.to_f)
    # $stderr.puts "m = #{m}"
    assert_equal_float((1.0 / usd_cad) * usd_eur, m, 0.001)
  end


  def test_reload
    # @cache.verbose = 5

    test_timed_cache_cad_eur

    assert_not_nil rates = @source.raw_rates
    assert_not_nil rates[:USD]
    assert_not_nil usd_cad_1 = rates[:USD][:CAD]

    assert_not_nil t1 = @cache.rate_load_time
    assert_not_nil t1_reload = @cache.rate_reload_time
    assert t1_reload.to_i > t1.to_i

    @cache.time_to_live = 5
    @cache.time_to_live_fudge = 0

    # puts @cache.rate_reload_time.to_i - @cache.rate_load_time.to_i
    assert @cache.rate_reload_time.to_i - @cache.rate_load_time.to_i == @cache.time_to_live

    sleep 10

    test_timed_cache_cad_eur
    
    assert_not_nil t2 = @cache.rate_load_time
    assert t1.to_i != t2.to_i

    assert_not_nil rates = @source.raw_rates
    assert_not_nil rates[:USD]
    assert_not_nil usd_cad_2 = rates[:USD][:CAD]

    assert usd_cad_1.object_id != usd_cad_2.object_id
  end

end

end # module

