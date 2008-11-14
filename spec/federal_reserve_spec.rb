# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'test/test_base'

require 'currency' # For :type => :money
require 'currency/exchange/rate/source/federal_reserve'

module Currency

class FederalReserveTest < TestBase
  before do
    super
  end


  @@available = nil

  # New York Fed rates are not available on Saturday and Sunday.
  def available?
    if @@available == nil
      @@available = @source.available?
      STDERR.puts "Warning: FederalReserve unavailable on Saturday and Sunday, skipping tests." unless @@available
    end
    @@available
  end


  def get_rate_source
    # Force FederalReserve Exchange.
    verbose = false
    source = @source = Exchange::Rate::Source::FederalReserve.new(:verbose => verbose)
    deriver = Exchange::Rate::Deriver.new(:source => source, :verbose => source.verbose)
  end



  it "usd cad" do
    return unless available?

    # yesterday = Time.now.to_date - 1

    rates = Exchange::Rate::Source.default.source.raw_rates.should_not == nil
    #assert_not_nil rates[:USD]
    #assert_not_nil usd_cad = rates[:USD][:CAD]

    usd = Money.new(123.45, :USD).should_not == nil
    cad = usd.convert(:CAD).should_not == nil

    # assert_kind_of Numeric, m = (cad.to_f / usd.to_f)
    # $stderr.puts "m = #{m}"
    # assert_equal_float usd_cad, m, 0.001
  end


  it "cad eur" do
    return unless available?

    rates = Exchange::Rate::Source.default.source.raw_rates.should_not == nil
    #assert_not_nil rates[:USD]
    #assert_not_nil usd_cad = rates[:USD][:CAD]
    #assert_not_nil usd_eur = rates[:USD][:EUR]

    cad = Money.new(123.45, :CAD).should_not == nil
    eur = cad.convert(:EUR).should_not == nil

    #assert_kind_of Numeric, m = (eur.to_f / cad.to_f)
    # $stderr.puts "m = #{m}"
    #assert_equal_float (1.0 / usd_cad) * usd_eur, m, 0.001
  end

end

end # module

