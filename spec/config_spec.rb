require File.dirname(__FILE__) + '/spec_helper'

describe Currency::Config do

  it "should truncate" do
    Currency::Config.configure do | c |
      c.float_ref_filter = Proc.new { | x | x }
    
      m = Currency::Money.new(1.999999999)
      m.should be_kind_of(Currency::Money) 
      m.rep.should == 1999999
    end
  end
  
  it "should round" do
    Currency::Config.configure do | c |
      c.float_ref_filter = Proc.new { | x | x.round }

      m = Currency::Money.new(1.99999999)
      m.should be_kind_of(Currency::Money)
      m.rep.should == 2000000
    end

  end

end # class



