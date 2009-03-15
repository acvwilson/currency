# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# Copyright (C) 2008 Asa Wilson <acvwilson(at)gmail.com>
# Copyright (C) 2009 David Palm <dvdplm(at)gmail.com>
# See LICENSE.txt for details.

require File.dirname(__FILE__) + '/ar_spec_helper'

class Dog < ActiveRecord::Base
  attr_money :price, :currency_column => true, :allow_nil => true
end

describe "extending ActiveRecord" do
  describe "attr_money" do
    before do
      Dog.connection.execute("INSERT INTO dogs VALUES(null, 'fido', 1500, 'USD')") # NOTE: by-passing AR here to achieve clean slate (dvd, 15-03-2009)
      @dog = Dog.first
    end

    describe "retrieving money values" do
      it "sets up the Money object at first read" do
        pending
      end
      
      it "returns the ivar on subsequent reads" do
        pending
      end
      
      it "does not setup a Money object if the db column does not contain an integer to use for money rep" do
        pending
      end
      
      it "casts the currency to the preferred one, if a preferred currency was set" do
        pending
      end
    end
    
    describe "currency column" do
      before do
        Dog.connection.execute("INSERT INTO dogs VALUES(null, 'fido', 1500, 'USD')") # NOTE: by-passing AR here to achieve clean slate (dvd, 15-03-2009)
        @dog = Dog.first
      end

      it "changes the currency when the value on the currency column changes" do
        @dog.price.currency.code.should == :USD
        @dog.update_attributes(:price_currency => 'EUR')
        @dog.price.currency.code.should == :EUR
      end
      
      it "does NOT convert to the new currency when the currency column changes" do
        @dog.price.rep.should == 1500
        @dog.update_attributes(:price_currency => :EUR)
        @dog.price.rep.should == 1500
      end
    end
    
    describe "saving" do
      it "saves the price with the default currency when set to 10.money" do
        @dog.price = 10.money
        @dog.price.should == Currency::Money("10")
      end
      
      it "saves the price with the currency of the Money object" do
        @dog.price = 10.money(:EUR)
        @dog.price.should == Currency::Money("10", "EUR")
      end
      
      it "can change just the currency" do
        @dog.price_currency = 'CAD'
        @dog.save
        @dog.price.should == Currency::Money("15", "CAD")
      end
      
      it "can save changes using update_attributes" do
        @dog.update_attributes(:price => 5, :price_currency => 'CAD')
        @dog.price.should == 5.money('CAD')
      end
    end

  end
end