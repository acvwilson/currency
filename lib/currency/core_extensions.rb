# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.



class Object 
  # Exact conversion to Money representation value.
  def money(*opts)
    Currency::Money(self, *opts)
  end
end



class Integer 
  # Exact conversion to Money representation value.
  def Money_rep(currency, time = nil)
    Integer(self * currency.scale)
  end
end



class Float 
  # Inexact conversion to Money representation value.
  def Money_rep(currency, time = nil)  
    Integer(Currency::Config.current.float_ref_filter.call(self * currency.scale))
  end
  
  def round_with_precision(precision = nil)
    precision.nil? ? round_without_precision : (self * (10 ** precision)).round_without_precision / (10 ** precision).to_f
  end
  alias_method :round_without_precision, :round
  alias_method :round, :round_with_precision
end




class String
  # Exact conversion to Money representation value.
  def Money_rep(currency, time = nil)
    x = currency.parse(self, :currency => currency, :time => time)
    x = x.rep if x.respond_to?(:rep)
    x
  end
end

