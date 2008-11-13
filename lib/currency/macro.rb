# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

class Currency::Money
    @@money_attributes = { }

    # Called by money macro when a money attribute
    # is created.
    def self.register_money_attribute(attr_opts)
      (@@money_attributes[attr_opts[:class]] ||= { })[attr_opts[:attr_name]] = attr_opts
    end

    # Returns an array of option hashes for all the money attributes of
    # this class.
    #
    # Superclass attributes are not included.
    def self.money_attributes_for_class(cls)
      (@@money_atttributes[cls] || { }).values
    end

    # Iterates through all known money attributes in all classes.
    #
    # each_money_attribute { | money_opts |
    #   ...
    # }
    def self.each_money_attribute(&blk)
      @@money_attributes.each do | cls, hash |
        hash.each do | attr_name, attr_opts |
          yield attr_opts
        end
      end
    end
    
end # class


module Currency::Macro
    def self.append_features(base) # :nodoc:
      # $stderr.puts "  Currency::ActiveRecord#append_features(#{base})"
      super
      base.extend(ClassMethods)
    end



# == Macro Suppport
#
# Support for Money attributes.
#
#    require 'currency'
#    require 'currency/macro'
#    
#    class SomeClass
#      include ::Currency::Macro
#      attr_accessor :amount
#      attr_money :amount_money, :value => :amount, :currency_fixed => :USD, :rep => :float
#    end
# 
#    x = SomeClass.new
#    x.amount = 123.45
#    x.amount
#    # => 123.45
#    x.amount_money
#    # => $123.45 USD
#    x.amount_money = x.amount_money + "12.45"
#    # => $135.90 USD
#    x.amount
#    # => 135.9
#    x.amount = 45.951
#    x.amount_money
#    # => $45.95 USD
#    x.amount
#    # => 45.951
#
    module ClassMethods

      # Defines a Money object attribute that is bound
      # to other attributes. 
      #
      # Options:
      #
      #    :value => undef
      #
      # Defines the value attribute to use for storing the money value.
      # Defaults to the attribute name.
      #
      # If this attribute is different from the attribute name,
      # the money object will intercept #{value}=(x) to flush
      # any cached Money object.
      #
      #    :readonly => false
      #
      # If true, the underlying attribute is readonly.  Thus the Money object
      # cannot be cached.  This is useful for computed money values.
      #
      #    :rep => :float
      #
      # This option specifies how the value attribute stores Money values.
      # if :rep is :rep, then the value is stored as a scaled integer as
      # defined by the Currency.  
      # If :rep is :float, or :integer the corresponding #to_f or #to_i
      # method is used.
      # Defaults to :float.
      #
      #    :currency => undef
      #
      # Defines the attribute used to store and
      # retrieve the Money's Currency 3-letter ISO code.
      #
      #    :currency_fixed => currency_code (e.g.: :USD)
      #
      # Defines the Currency to use for storing a normalized Money 
      # value.
      #
      # All Money values will be converted to this Currency before
      # storing.  This allows SQL summary operations, 
      # like SUM(), MAX(), AVG(), etc., to produce meaningful results,
      # regardless of the initial currency specified.  If this
      # option is used, subsequent reads will be in the specified
      # normalization :currency_fixed.
      #
      #    :currency_preferred => undef
      #
      # Defines the name of attribute used to store and
      # retrieve the Money's Currency ISO code.  This option can be used
      # with normalized Money values to retrieve the Money value 
      # in its original Currency, while
      # allowing SQL summary operations on the normalized Money values
      # to still be valid.
      #
      #    :currency_update => undef
      #
      # If true, the currency attribute is updated upon setting the
      # money attribute.  
      # 
      #    :time => undef
      #
      # Defines the attribute used to 
      # retrieve the Money's time.  If this option is used, each
      # Money value will use this attribute during historical Currency
      # conversions.
      #
      # Money values can share a time value with other attributes
      # (e.g. a created_on column in ActiveRecord::Base).
      #
      # If this option is true, the money time attribute will be named
      # "#{attr_name}_time" and :time_update will be true.
      #
      #    :time_update => undef
      #
      # If true, the Money time value is updated upon setting the
      # money attribute.  
      #
      def attr_money(attr_name, *opts)
        opts = Hash[*opts]

        attr_name = attr_name.to_s
        opts[:class] = self
        opts[:name] = attr_name.intern
        ::Currency::Money.register_money_attribute(opts)

        value = opts[:value] || opts[:name]
        opts[:value] = value
        write_value = opts[:write_value] ||= "self.#{value} = "

        # Intercept value setter?
        if ! opts[:readonly] && value.to_s != attr_name.to_s
          alias_accessor = <<-"end_eval"
alias :before_money_#{value}= :#{value}=

def #{value}=(__value)
  @#{attr_name} = nil # uncache
  self.before_money_#{value} = __value
end

end_eval
        end 

        # How to convert between numeric representation and Money.
        rep = opts[:rep] ||= :float
        to_rep = opts[:to_rep]
        from_rep = opts[:from_rep]
        if rep == :rep
          to_rep = 'rep'
          from_rep = '::Currency::Money.new_rep'
        else
          case rep
          when :float
            to_rep = 'to_f'
          when :integer
            to_rep = 'to_i'
          else
            raise ::Currency::Exception::InvalidMoneyValue, "Cannot use value representation: #{rep.inspect}"
          end
          from_rep = '::Currency::Money.new'
        end
        to_rep = to_rep.to_s
        from_rep = from_rep.to_s

        # Money time values.
        time = opts[:time]
        write_time = ''
        if time
          if time == true
            time = "#{attr_name}_time"
            opts[:time_update] = true
          end
          read_time = "self.#{time}"
        end
        opts[:time] = time
        if opts[:time_update]
          write_time = "self.#{time} = #{attr_name}_money && #{attr_name}_money.time"
        end
        time ||= 'nil'
        read_time ||= time

        currency_fixed = opts[:currency_fixed]
        currency_fixed &&= ":#{currency_fixed}"

        currency = opts[:currency]
        if currency == true
          currency = currency.to_s
          currency = "self.#{attr_name}_currency"
        end
        if currency
          read_currency = "self.#{currency}"
          if opts[:currency_update]
            write_currency = "self.#{currency} = #{attr_name}_money.nil? ? nil : #{attr_name}_money.currency.code"
          else
            convert_currency = "#{attr_name}_money = #{attr_name}_money.convert(#{read_currency}, #{read_time})"
          end
        end
        opts[:currency] = currency
        write_currency ||= ''
        convert_currency ||= ''

        currency_preferred = opts[:currency_preferred]
        if currency_preferred
          currency_preferred = currency_preferred.to_s
          read_preferred_currency = "@#{attr_name} = @#{attr_name}.convert(#{currency_preferred}, #{read_time})"
          write_preferred_currency = "self.#{currency_preferred} = @#{attr_name}_money.currency.code"
        end

        currency ||= currency_fixed
        read_currency ||= currency

        alias_accessor ||= ''

        validate ||= ''

        if opts[:readonly]
          eval_opts = [ (opts[:module_eval] = x = <<-"end_eval"), __FILE__, __LINE__ ]
#{validate}

def #{attr_name}
  #{attr_name}_rep = #{value}
  if #{attr_name}_rep != nil
    #{attr_name} = #{from_rep}(#{attr_name}_rep, #{read_currency} || #{currency}, #{read_time} || #{time})
    #{read_preferred_currency}
  else
    #{attr_name} = nil
  end
  #{attr_name}
end

end_eval
        else
          eval_opts = [ (opts[:module_eval] = x = <<-"end_eval"), __FILE__, __LINE__ ]
#{validate}

#{alias_accessor}

def #{attr_name}
  unless @#{attr_name}
    #{attr_name}_rep = #{value}
    if #{attr_name}_rep != nil
      @#{attr_name} = #{from_rep}(#{attr_name}_rep, #{read_currency} || #{currency}, #{read_time} || #{time})
      #{read_preferred_currency}
    end
  end
  @#{attr_name}
end


def #{attr_name}=(value)
  if value == nil
    #{attr_name}_money = nil
  elsif value.kind_of?(Integer) || value.kind_of?(Float) || value.kind_of?(String)
    #{attr_name}_money = ::Currency.Money(value, #{read_currency}, #{read_time})
    #{write_preferred_currency}
  elsif value.kind_of?(::Currency::Money)
    #{attr_name}_money = value
    #{write_preferred_currency}
    #{convert_currency}
  else
    raise ::Currency::Exception::InvalidMoneyValue, value
  end

  @#{attr_name} = #{attr_name}_money
  #{write_value}(#{attr_name}_money.nil? ? nil : #{attr_name}_money.#{to_rep})
  #{write_currency}
  #{write_time}

  value
end

end_eval
      end

      # $stderr.puts "   CODE = #{x}"
      module_eval(*eval_opts)
    end
  end # module
end # module


# Use include ::Currency::Macro
#::Object.class_eval do
#  include Currency::Macro
#end

