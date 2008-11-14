# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'test/test_base'

require 'currency' # For :type => :money
require 'currency/exchange/rate/source/new_york_fed'

module Currency

class NewYorkFedTest < TestBase
  before do
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



  it "usd cad" do
    return unless available?

    rates = Exchange::Rate::Source.default.source.raw_rates.should.not == nil
    rates[:USD].should.not == nil
    usd_cad = rates[:USD][:CAD].should.not == nil

    usd = Money.new(123.45, :USD).should.not == nil
    cad = usd.convert(:CAD).should.not == nil

    assert_kind_of Numeric, m = (cad.to_f / usd.to_f)
    # $stderr.puts "m = #{m}"
    assert_equal_float usd_cad, m, 0.001
  end


  it "cad eur" do
    return unless available?

    rates = Exchange::Rate::Source.default.source.raw_rates.should.not == nil
    rates[:USD].should.not == nil
    usd_cad = rates[:USD][:CAD].should.not == nil
    usd_eur = rates[:USD][:EUR].should.not == nil

    cad = Money.new(123.45, :CAD).should.not == nil
    eur = cad.convert(:EUR).should.not == nil

    assert_kind_of Numeric, m = (eur.to_f / cad.to_f)
    # $stderr.puts "m = #{m}"
    assert_equal_float (1.0 / usd_cad) * usd_eur, m, 0.001
  end

end

end # module

