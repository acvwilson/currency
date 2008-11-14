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

# module Asa
#   module Rounding
#     def self.included(base) #:nodoc:
#       puts "included by #{base.inspect}"
#       base.class_eval do
#         alias_method :round_without_precision, :round
#         alias_method :round, :round_with_precision
#       end
#     end
# 
#     # Rounds the float with the specified precision.
#     #
#     #   x = 1.337
#     #   x.round    # => 1
#     #   x.round(1) # => 1.3
#     #   x.round(2) # => 1.34
#     def round_with_precision(precision = nil)
#       precision.nil? ? round_without_precision : (self * (10 ** precision)).round / (10 ** precision).to_f
#     end
#     
#   end
# end
# 
# class Float 
#   include Asa::Rounding
#   # Inexact conversion to Money representation value.
#   def Money_rep(currency, time = nil)  
#     Integer(Currency::Config.current.float_ref_filter.call(self * currency.scale))
#   end
# end

class Float 
  # Inexact conversion to Money representation value.
  def Money_rep(currency, time = nil)  
    Integer(Currency::Config.current.float_ref_filter.call(self * currency.scale))
  end
  
  # def round_with_awesome_precision(precision = nil)
  #   # puts "self: #{self.inspect}"
  #   # puts "precision: #{precision.inspect}"
  #   # puts "round_without_precision: #{round_without_precision.inspect}"
  #   # puts "self * (10 ** precision): #{(self * (10 ** precision)).inspect}"
  #   # puts "(self * (10 ** precision)).round_without_precision: #{((self * (10 ** precision)).round_without_precision).inspect}"
  #   # self.to_s.to_f.round_without_precision
  #   precision.nil? ? round_without_awesome_precision : (self * (10 ** precision)).round_without_awesome_precision / (10 ** precision).to_f
  # end
  # alias_method :round_without_awesome_precision, :round
  # alias_method :round, :round_with_awesome_precision
end




class String
  # Exact conversion to Money representation value.
  def Money_rep(currency, time = nil)
    x = currency.parse(self, :currency => currency, :time => time)
    x = x.rep if x.respond_to?(:rep)
    x
  end
end

