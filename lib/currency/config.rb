# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

# The Currency::Config class is responsible for
# maintaining global configuration for the Currency package.
#
# TO DO:
# 
# Migrate all class variable configurations to this object.
# Rewrite this whole class. It is not working at all after first config
# Threads are bad. Use the Singleton library when rewriting this
class Currency::Config
  # Returns the default Currency::Config object.
  #
  # If one is not specfied an instance is
  # created.  This is a global, not thread-local.
  def self.default 
    @@default ||= self.new
  end
  
  # Sets the default Currency::Config object.
  def self.default=(x)
    @@default = x
    Currency::Currency::Factory.reset
    @@default
  end
  
  # Returns the current Currency::Config object
  # If #current= has not been called and #default= has not been called,
  # then UndefinedExchange is raised.
  def self.current
    self.default || (raise ::Currency::Exception::UndefinedConfig, "Currency::Config.default not defined")
  end
  
  # Sets the current Currency::Config object used
  # in the current thread.
  def self.current=(x)
    self.default = x
  end

  # Clones the current configuration and makes it current
  # during the execution of a block.  After block completes,
  # the previous configuration is restored.
  #
  #   Currency::Config.configure do | c |
  #     c.float_ref_filter = Proc.new { | x | x.round }
  #     "123.448".money.rep == 12345
  #   end
  # TODO: rewrite from scratch
  def self.configure(&blk)
    c_prev = current
    c_new = self.current = current.clone
    result = nil
    begin
      result = yield c_new
    rescue
      self.current = c_prev
    end
    result
  end

  
  # Returns the current Float conversion filter.
  # Can be used to set rounding or truncation policies when converting
  # Float values to Money values.
  # Defaults to an identity function.
  # See Float#Money_rep.
  attr_accessor :float_ref_filter
  def float_ref_filter
    @float_ref_filter ||= Proc.new { |x| x }
  end
  
  # Defines the table name for Historical::Rate records.
  # Defaults to 'currency_historical_rates'.
  attr_accessor :historical_table_name
  def historical_table_name
    @historical_table_name ||= 'currency_historical_rates'
  end
  
  attr_accessor :scale_exp
  def scale_exp=(val)
    raise ArgumentError, "Invalid scale exponent" unless val.integer?
    raise ArgumentError, "Invalid scale: zero" if val.zero?
    @scale_exp = val
    Currency::Currency::Factory.reset
  end

  attr_reader :scale
  def scale
    10 ** (scale_exp || 2)
  end
  
end