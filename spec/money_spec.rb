require File.dirname(__FILE__) + '/spec_helper'


describe Currency::Money do

  it "create" do
    m = Currency::Money.new(1.99)
    m.should be_kind_of(Currency::Money) 
    Currency::Currency.default.should == m.currency
    :USD.should == m.currency.code
  end

  describe "object money method" do
    it "works with a float" do
      m = 1.99.money(:USD)
      m.should be_kind_of(Currency::Money)
      :USD.should == m.currency.code
      m.rep.should == 1990000
    end

    it "works with a FixNum" do
      m = 199.money(:CAD)
      m.should be_kind_of(Currency::Money)
      :CAD.should == m.currency.code
      m.rep.should == 199000000
    end

    it "works with a string" do
      m = "13.98".money(:CAD)
      m.should be_kind_of(Currency::Money)
      :CAD.should == m.currency.code
      m.rep.should == 13980000
    end

    it "works with a string again" do
      m = "45.99".money(:EUR)
      m.should be_kind_of(Currency::Money)
      :EUR.should == m.currency.code
      m.rep.should == 45990000
    end
    
    it "creates money objects from strings" do
       "12.0001".money(:USD).to_s.should == "$12.0001"
       # "12.000108".money(:USD).to_s(:thousands => false, :decimals => 5).should == "$12.00011"
       @money = Currency::Money.new_rep(1234567890000, :USD, nil)
       
       Currency::Money.new("12.000108").to_s(:thousands => false, :decimals => 5).should == "$12.00011"
    end
  end

  def zero_money
    @zero_money ||= Currency::Money.new(0)
  end
  
  it "zero" do
    zero_money.negative?.should_not == true
    zero_money.zero?.should_not == nil
    zero_money.positive?.should_not == true
  end
  
  def negative_money
    @negative_money ||= Currency::Money.new(-1.00, :USD)
  end
  
  it "negative" do
    negative_money.negative?.should_not == nil
    negative_money.zero?.should_not == true
    negative_money.positive?.should_not == true
  end

  def positive_money
    @positive_money ||= Currency::Money.new(2.99, :USD)
  end
  it "positive" do
    positive_money.negative?.should_not == true
    positive_money.zero?.should_not == true
    positive_money.positive?.should_not == nil
  end

  it "relational" do
    n = negative_money
    z = zero_money
    p = positive_money

    (n.should < p)
     (n > p).should_not == true
     (p < n).should_not == true
    (p.should > n)
    (p != n).should_not == nil

    (z.should <= z)
    (z.should >= z)

    (z.should <= p)
    (n.should <= z)
    (z.should >= n)

    n.should == n
    p.should == p

    z.should == zero_money
  end

  it "compare" do
    n = negative_money
    z = zero_money
    p = positive_money

    (n <=> p).should == -1
    (p <=> n).should == 1
    (p <=> z).should == 1

    (n <=> n).should == 0
    (z <=> z).should == 0
    (p <=> p).should == 0    
  end

  it "rep" do
    m = Currency::Money.new(123, :USD)
    m.should_not == nil
    m.rep.should == 123000000
    
    m = Currency::Money.new(123.45, :USD)
    m.should_not == nil
    m.rep.should == 123450000

    m = Currency::Money.new("123.456", :USD)
    m.should_not == nil
    m.rep.should == 123456000
  end

  it "convert" do
    m = Currency::Money.new("123.456", :USD)
    m.should_not == nil
    m.rep.should == 123456000

    m.to_i.should == 123
    m.to_f.should == 123.456
    m.to_s.should == "$123.456000"
  end

  it "eql" do
    usd1 = Currency::Money.new(123, :USD)
    usd1.should_not == nil
    usd2 = Currency::Money.new("123", :USD)
    usd2.should_not == nil

    usd1.currency.code.should == :USD
    usd2.currency.code.should == :USD
    
    usd2.rep.should == usd1.rep

    usd1.should == usd2

  end

  it "not eql" do  
 
    usd1 = Currency::Money.new(123, :USD)
    usd1.should_not == nil
    usd2 = Currency::Money.new("123.01", :USD)
    usd2.should_not == nil

    usd1.currency.code.should == :USD
    usd2.currency.code.should == :USD
    
    usd2.rep.should_not == usd1.rep

    (usd1 != usd2).should_not == nil

    ################
    # currency !=
    # rep ==

    usd = Currency::Money.new(123, :USD)
    usd.should_not == nil
    cad = Currency::Money.new(123, :CAD)
    cad.should_not == nil

    usd.currency.code.should == :USD
    cad.currency.code.should == :CAD

    cad.rep.should == usd.rep
    (usd.currency != cad.currency).should_not == nil

    (usd != cad).should_not == nil

  end
  
  describe "operations" do
    before(:each) do
      @usd = Currency::Money.new(123.45, :USD)
      @cad = Currency::Money.new(123.45, :CAD)
    end
    
    it "should work" do
      @usd.should_not == nil
      @cad.should_not == nil
    end
    
    it "handle negative money" do
      # - Currency::Money => Currency::Money
      (- @usd).rep.should == -123450000
      (- @usd).currency.code.should == :USD

      (- @cad).rep.should == -123450000
      (- @cad).currency.code.should == :CAD
    end
    
    it "should add monies of the same currency" do
      m = (@usd + @usd)
      m.should be_kind_of(Currency::Money)
      m.rep.should == 246900000
      m.currency.code.should == :USD
    end
    
    it "should add monies of different currencies and return USD" do
      m = (@usd + @cad)
      m.should be_kind_of(Currency::Money)
      m.rep.should == 228890724
      m.currency.code.should == :USD
    end
    
    it "should add monies of different currencies and return CAD" do
      m = (@cad + @usd)
      m.should be_kind_of(Currency::Money) 
      m.rep.should == 267985260
      m.currency.code.should == :CAD
    end
    
    it "should subtract monies of the same currency" do
      m = (@usd - @usd)
      m.should be_kind_of(Currency::Money) 
      m.rep.should == 0
      m.currency.code.should == :USD
    end
    
    it "should subtract monies of different currencies and return USD" do
      m = (@usd - @cad)
      m.should be_kind_of(Currency::Money) 
      m.rep.should == 18009276
      m.currency.code.should == :USD
    end
    
    it "should subtract monies of different currencies and return CAD" do
      m = (@cad - @usd)
      m.should be_kind_of(Currency::Money) 
      m.rep.should == -21085260
      m.currency.code.should == :CAD
    end
    
    it "should multiply by numerics and return money" do
      m = (@usd * 0.5)
      m.should be_kind_of(Currency::Money)
      m.rep.should == 61725000
      m.currency.code.should == :USD
    end
    
    it "should divide by numerics and return money" do
      m = @usd / 3
      m.should be_kind_of(Currency::Money)
      m.rep.should == 41150000
      m.currency.code.should == :USD
    end
    
    it "should divide by monies of the same currency and return numeric" do
      m = @usd / Currency::Money.new("41.15", :USD)
      m.should be_kind_of(Numeric)
      m.should be_close(3.0, 1.0e-8)
    end
    
    it "should divide by monies of different currencies and return numeric" do
      m = (@usd / @cad)
      m.should be_kind_of(Numeric)
      m.should be_close(Currency::Exchange::Rate::Source::Test.USD_CAD, 0.0001)
    end
  end

  it "pivot conversions" do
    # Using default get_rate
    cad = Currency::Money.new(123.45, :CAD)
    cad.should_not == nil
    eur = cad.convert(:EUR)
    eur.should_not == nil
    m = (eur.to_f / cad.to_f)
    m.should be_kind_of(Numeric) 
    m_expected = (1.0 / Currency::Exchange::Rate::Source::Test.USD_CAD) * Currency::Exchange::Rate::Source::Test.USD_EUR
    m.should be_close(m_expected, 0.001)


    gbp = Currency::Money.new(123.45, :GBP)
    gbp.should_not == nil
    eur = gbp.convert(:EUR)
    eur.should_not == nil
    m = (eur.to_f / gbp.to_f)
    m.should be_kind_of(Numeric) 
    m_expected = (1.0 / Currency::Exchange::Rate::Source::Test.USD_GBP) * Currency::Exchange::Rate::Source::Test.USD_EUR
    m.should be_close(m_expected, 0.001)
  end


  it "invalid currency code" do
    lambda {Currency::Money.new(123, :asdf)}.should raise_error(Currency::Exception::InvalidCurrencyCode)
    lambda {Currency::Money.new(123, 5)}.should raise_error(Currency::Exception::InvalidCurrencyCode)
  end


  it "time default" do
    Currency::Money.default_time = nil

    usd = Currency::Money.new(123.45, :USD)
    usd.should_not == nil
    usd.time.should == nil

    Currency::Money.default_time = Time.now
    usd = Currency::Money.new(123.45, :USD)
    usd.should_not == nil
    Currency::Money.default_time.should == usd.time
  end


  it "time now" do
    Currency::Money.default_time = :now

    usd = Currency::Money.new(123.45, :USD)
    usd.should_not == nil
    usd.time.should_not == nil

    sleep 1

    usd2 = Currency::Money.new(123.45, :USD)
    usd2.should_not == nil
    usd2.time.should_not == nil
    (usd.time != usd2.time).should_not == nil

    Currency::Money.default_time = nil
  end


  it "time fixed" do
    Currency::Money.default_time = Time.new

    usd = Currency::Money.new(123.45, :USD)
    usd.should_not == nil
    usd.time.should_not == nil

    sleep 1

    usd2 = Currency::Money.new(123.45, :USD)
    usd2.should_not == nil
    usd2.time.should_not == nil
    usd.time.should == usd2.time
  end
end

