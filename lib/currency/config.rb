# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

# The Currency::Config class is responsible for
# maintaining global configuration for the Currency package.
#
# TO DO:
# 
# Migrate all class variable configurations to this object.
class Currency::Config
  @@default = nil

  # Returns the default Currency::Config object.
  #
  # If one is not specfied an instance is
  # created.  This is a global, not thread-local.
  def self.default 
    @@default ||= 
      self.new
  end
  
  # Sets the default Currency::Config object.
  def self.default=(x)
    @@default = x
  end
  
  # Returns the current Currency::Config object used during
  # in the current thread.
  #
  # If #current= has not been called and #default= has not been called,
  # then UndefinedExchange is raised.
  def self.current
    Thread.current[:Currency__Config] ||= 
      self.default || 
      (raise ::Currency::Exception::UndefinedConfig, "Currency::Config.default not defined")
  end
  
  # Sets the current Currency::Config object used
  # in the current thread.
  def self.current=(x)
    Thread.current[:Currency__Config] = x
  end

  # Clones the current configuration and makes it current
  # during the execution of a block.  After block completes,
  # the previous configuration is restored.
  #
  #   Currency::Config.configure do | c |
  #     c.float_ref_filter = Proc.new { | x | x.round }
  #     "123.448".money.rep == 12345
  #   end
  def self.configure(&blk)
    c_prev = current
    c_new = self.current = current.clone
    result = nil
    begin
      result = yield c_new
    ensure
      self.current = c_prev
    end
    result
  end

  
  @@identity = Proc.new { |x| x } # :nodoc:
  
  # Returns the current Float conversion filter.
  # Can be used to set rounding or truncation policies when converting
  # Float values to Money values.
  # Defaults to an identity function.
  # See Float#Money_rep.
  def float_ref_filter
    @float_ref_filter ||= 
      @@identity
  end
  
  # Sets the current Float conversion filter.
  def float_ref_filter=(x)
    @float_ref_filter = x
  end

  
  # Defines the table name for Historical::Rate records.
  # Defaults to 'currency_historical_rates'.
  attr_accessor :historical_table_name
  def historical_table_name
    @historical_table_name ||= 'currency_historical_rates'
  end

end # module

