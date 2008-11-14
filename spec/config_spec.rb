require File.dirname(__FILE__) + '/spec_helper'

describe Currency::Config do

  it "config" do
    m = Currency::Money.new(1.999)
    m.should be_kind_of(Currency::Money) 
    m.rep.should == 19990

    Currency::Config.configure do | c |
      c.float_ref_filter = Proc.new { | x | x.round }

      m = Currency::Money.new(1.99999999)
      m.should be_kind_of(Currency::Money)
      m.rep.should == 20000
    end

  end

end # class



