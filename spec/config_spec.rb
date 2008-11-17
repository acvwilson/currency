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
  
  describe "the scale expression is configurable" do
    before(:all) do
      @config = Currency::Config.new
    end
    
    before(:each) do
      Currency::Config.current = nil
      Currency::Config.send(:class_variable_set, "@@default", nil)
    end
    
    it "should have a scale_exp setter" do
      Currency::Config.current.should respond_to(:scale_exp=)
    end
    
    it "has a 'scale' reader" do
      Currency::Config.current.should respond_to(:scale)
    end
    
    it "uses the scale reader from the config when creating new Money object" do
      Currency::Config.should_receive(:current).and_return(@config)
      @config.should_receive(:scale).and_return(100)
      10.money
    end
    
    it "can be configured using a block" do
      Currency::Config.configure do |config|
        config.scale_exp = 6
      end

      10.money.currency.scale_exp.should == 6
      
      Currency::Config.configure do |config|
        config.scale_exp = 4
      end
      10.money.currency.scale_exp.should == 4
    end
    
    it "can be configured using straight setters" do
      10.money(:USD).currency.scale_exp.should == 2
      Currency::Config.current.scale_exp = 6
      10.money(:USD).currency.scale_exp.should == 6
    end
  end

end