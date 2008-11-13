# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'active_record/base'
require File.join(File.dirname(__FILE__), '..', 'currency')

# See Currency::ActiveRecord::ClassMethods
class ActiveRecord::Base
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


# See Currency::ActiveRecord::ClassMethods
module Currency::ActiveRecord
    
    def self.append_features(base) # :nodoc:
      # $stderr.puts "  Currency::ActiveRecord#append_features(#{base})"
      super
      base.extend(ClassMethods)
    end



# == ActiveRecord Suppport
#
# Support for Money attributes in ActiveRecord::Base subclasses:
#
#    require 'currency'
#    require 'currency/active_record'
#    
#    class Entry < ActiveRecord::Base
#       attr_money :amount
#    end
# 
    module ClassMethods

      # Deprecated: use attr_money.
      def money(*args)
        $stderr.puts "WARNING: money(#{args.inspect}) deprecated, use attr_money: in #{caller(1)[0]}"
        attr_money(*args)
      end


      # Defines a Money object attribute that is bound
      # to a database column.  The database column to store the
      # Money value representation is assumed to be
      # INTEGER and will store Money#rep values.
      #
      # Options:
      #
      #    :column => undef
      #
      # Defines the column to use for storing the money value.
      # Defaults to the attribute name.
      #
      # If this column is different from the attribute name,
      # the money object will intercept column=(x) to flush
      # any cached Money object.
      #
      #    :currency => currency_code (e.g.: :USD)
      #
      # Defines the Currency to use for storing a normalized Money 
      # value.
      #
      # All Money values will be converted to this Currency before
      # storing.  This allows SQL summary operations, 
      # like SUM(), MAX(), AVG(), etc., to produce meaningful results,
      # regardless of the initial currency specified.  If this
      # option is used, subsequent reads will be in the specified
      # normalization :currency.
      #
      #    :currency_column => undef
      #
      # Defines the name of the CHAR(3) column used to store and
      # retrieve the Money's Currency code.  If this option is used, each
      # record may use a different Currency to store the result, such
      # that SQL summary operations, like SUM(), MAX(), AVG(), 
      # may return meaningless results.
      #
      #    :currency_preferred_column => undef
      #
      # Defines the name of a CHAR(3) column used to store and
      # retrieve the Money's Currency code.  This option can be used
      # with normalized Money values to retrieve the Money value 
      # in its original Currency, while
      # allowing SQL summary operations on the normalized Money values
      # to still be valid.
      #
      #    :time => undef
      #
      # Defines the name of attribute used to 
      # retrieve the Money's time.  If this option is used, each
      # Money value will use this attribute during historical Currency
      # conversions.
      #
      # Money values can share a time value with other attributes
      # (e.g. a created_on column).
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
        opts[:table] = self.table_name
        opts[:attr_name] = attr_name.intern
        ::ActiveRecord::Base.register_money_attribute(opts)

        column = opts[:column] || opts[:attr_name]
        opts[:column] = column

        if column.to_s != attr_name.to_s
          alias_accessor = <<-"end_eval"
alias :before_money_#{column}=, :#{column}=

def #{column}=(__value)
  @{attr_name} = nil # uncache
  before_money#{column} = __value
end

end_eval
        end

        currency = opts[:currency]

        currency_column = opts[:currency_column]
        if currency_column && ! currency_column.kind_of?(String)
          currency_column = currency_column.to_s
          currency_column = "#{column}_currency"
        end
        if currency_column
          read_currency = "read_attribute(:#{currency_column.to_s})"
          write_currency = "write_attribute(:#{currency_column}, #{attr_name}_money.nil? ? nil : #{attr_name}_money.currency.code.to_s)"
        end
        opts[:currency_column] = currency_column

        currency_preferred_column = opts[:currency_preferred_column]
        if currency_preferred_column
          currency_preferred_column = currency_preferred_column.to_s
          read_preferred_currency = "@#{attr_name} = @#{attr_name}.convert(read_attribute(:#{currency_preferred_column}))"
          write_preferred_currency = "write_attribute(:#{currency_preferred_column}, @#{attr_name}_money.currency.code)"
        end

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

        currency ||= ':USD'
        time ||= 'nil'

        read_currency ||= currency
        read_time ||= time

        money_rep ||= "#{attr_name}_money.rep"

        validate_allow_nil = opts[:allow_nil] ? ', :allow_nil => true' : ''
        validate = "# Validation\n"
        validate << "\nvalidates_numericality_of :#{attr_name}#{validate_allow_nil}\n"
        validate << "\nvalidates_format_of :#{currency_column}, :with => /^[A-Z][A-Z][A-Z]$/#{validate_allow_nil}\n" if currency_column

 
        alias_accessor ||= ''

        module_eval (opts[:module_eval] = x = <<-"end_eval"), __FILE__, __LINE__
#{validate}

#{alias_accessor}

def #{attr_name}
  # $stderr.puts "  \#{self.class.name}##{attr_name}"
  unless @#{attr_name}
    #{attr_name}_rep = read_attribute(:#{column})
    unless #{attr_name}_rep.nil?
      @#{attr_name} = ::Currency::Money.new_rep(#{attr_name}_rep, #{read_currency} || #{currency}, #{read_time} || #{time})
      #{read_preferred_currency}
    end
  end
  @#{attr_name}
end

def #{attr_name}=(value)
  if value.nil?
    #{attr_name}_money = nil
  elsif value.kind_of?(Integer) || value.kind_of?(String) || value.kind_of?(Float)
    #{attr_name}_money = ::Currency::Money(value, #{currency})
    #{write_preferred_currency}
  elsif value.kind_of?(::Currency::Money)
    #{attr_name}_money = value
    #{write_preferred_currency}
    #{write_currency ? write_currency : "#{attr_name}_money = #{attr_name}_money.convert(#{currency})"}
  else
    raise ::Currency::Exception::InvalidMoneyValue, value
  end

  @#{attr_name} = #{attr_name}_money
  
  write_attribute(:#{column}, #{attr_name}_money.nil? ? nil : #{money_rep})
  #{write_time}

  value
end

def #{attr_name}_before_type_cast
  # FIXME: User cannot specify Currency
  x = #{attr_name}
  x &&= x.format(:symbol => false, :currency => false, :thousands => false)
  x
end

end_eval
        # $stderr.puts "   CODE = #{x}"
      end
    end
end


ActiveRecord::Base.class_eval do
  include Currency::ActiveRecord
end
