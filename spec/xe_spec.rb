# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'currency/exchange/rate/source/xe'

describe Currency::Exchange::Rate::Source::XE do
  
  before(:all) do
    get_rate_source
  end

  def get_rate_source
    source = Currency::Exchange::Rate::Source::XE.new
    Currency::Exchange::Rate::Deriver.new(:source => source)
  end

  it "xe usd cad" do
    rates = Currency::Exchange::Rate::Source.default.source.raw_rates
    rates.should_not == nil
    rates[:USD].should_not == nil
    usd_cad = rates[:USD][:CAD].should_not == nil

    usd = Currency::Money.new(123.45, :USD)
    usd.should_not == nil
    cad = usd.convert(:CAD).should_not == nil

    m = (cad.to_f / usd.to_f)
    m.should be_kind_of(Numeric) 
    m.should be_close(usd_cad, 0.001)
  end


  it "xe cad eur" do
    rates = Currency::Exchange::Rate::Source.default.source.raw_rates
    rates.should_not == nil
    rates[:USD].should_not == nil
    usd_cad = rates[:USD][:CAD].should_not == nil
    usd_eur = rates[:USD][:EUR].should_not == nil

    cad = Currency::Money.new(123.45, :CAD)
    cad.should_not == nil
    eur = cad.convert(:EUR)
    eur.should_not == nil

    m = (eur.to_f / cad.to_f)
    m.should be_kind_of(Numeric)
    m.should be_close((1.0 / usd_cad) * usd_eur, 0.001)
  end

end
