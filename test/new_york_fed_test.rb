# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'test/test_base'

require 'currency' # For :type => :money
require 'currency/exchange/rate/source/new_york_fed'

module Currency

class NewYorkFedTest < TestBase
  def setup
    super
  end


  @@available = nil

  # New York Fed rates are not available on Saturday and Sunday.
  def available?
    if @@available == nil
      @@available = @source.available?
      STDERR.puts "Warning: NewYorkFed unavailable on Saturday and Sunday, skipping tests."
    end
    @@available
  end


  def get_rate_source
    # Force NewYorkFed Exchange.
    verbose = false
    source = @source = Exchange::Rate::Source::NewYorkFed.new(:verbose => verbose)
    deriver = Exchange::Rate::Deriver.new(:source => source, :verbose => source.verbose)
  end



  def test_usd_cad
    return unless available?

    assert_not_nil rates = Exchange::Rate::Source.default.source.raw_rates
    assert_not_nil rates[:USD]
    assert_not_nil usd_cad = rates[:USD][:CAD]

    assert_not_nil usd = Money.new(123.45, :USD)
    assert_not_nil cad = usd.convert(:CAD)

    assert_kind_of Numeric, m = (cad.to_f / usd.to_f)
    # $stderr.puts "m = #{m}"
    assert_equal_float usd_cad, m, 0.001
  end


  def test_cad_eur
    return unless available?

    assert_not_nil rates = Exchange::Rate::Source.default.source.raw_rates
    assert_not_nil rates[:USD]
    assert_not_nil usd_cad = rates[:USD][:CAD]
    assert_not_nil usd_eur = rates[:USD][:EUR]

    assert_not_nil cad = Money.new(123.45, :CAD)
    assert_not_nil eur = cad.convert(:EUR)

    assert_kind_of Numeric, m = (eur.to_f / cad.to_f)
    # $stderr.puts "m = #{m}"
    assert_equal_float (1.0 / usd_cad) * usd_eur, m, 0.001
  end

end

end # module

