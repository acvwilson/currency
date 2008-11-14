# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'rss/rss' # Time#xmlschema


# This class formats a Money value as a String.
# Each Currency has a default Formatter.
class Currency::Formatter
  # The underlying object for Currency::Formatter#format.
  # This object is cloned and initialized with strings created
  # from Formatter#format.
  # It handles the Formatter#format string interpolation.
  class Template
    @@empty_hash = { }
    @@empty_hash.freeze

    # The template string.
    attr_accessor :template

    # The Currency::Money object being formatted.
    attr_accessor :money
    # The Currency::Currency object being formatted.
    attr_accessor :currency

    # The sign: '-' or nil.
    attr_accessor :sign
    # The whole part of the value, with thousands_separator or nil.
    attr_accessor :whole
    # The fraction part of the value, with decimal_separator or nil.
    attr_accessor :fraction
    # The currency symbol or nil.
    attr_accessor :symbol
    # The currency code or nil.
    attr_accessor :code

    # The time or nil.
    attr_accessor :time

    def initialize(opts = @@empty_hash)
      @template =
        @template_proc =
        nil

      opts.each_pair{ | k, v | self.send("#{k}=", v) }
    end


    # Sets the template string and uncaches the template_proc.
    def template=(x)
      if @template != x
        @template_proc = nil
      end
      @template = x
    end


    # Defines a the self._format template procedure using
    # the template as a string to be interpolated.
    def template_proc(template = @template)
      return @template_proc if @template_proc
      @template_proc = template || ''
      # @template_proc = @template_proc.gsub(/[\\"']/) { | x | "\\" + x }
      @template_proc = "def self._format; \"#{@template_proc}\"; end"
      self.instance_eval @template_proc
      @template_proc
    end


    # Formats the current state using the template.
    def format
      template_proc
      _format
    end
  end


  # Defaults to ','
  attr_accessor :thousands_separator

  # Defaults to '.'
  attr_accessor :decimal_separator

  # If true, insert _thousands_separator_ between each 3 digits in the whole value.
  attr_accessor :thousands

  # If true, append _decimal_separator_ and decimal digits after whole value.
  attr_accessor :cents
  
  # If true, prefix value with currency symbol.
  attr_accessor :symbol

  # If true, append currency code.
  attr_accessor :code

  # If true, append the time.
  attr_accessor :time

  # The number of fractional digits in the time.
  # Defaults to 4.
  attr_accessor :time_fractional_digits

  # If true, use html formatting.
  #
  #   Currency::Money(12.45, :EUR).to_s(:html => true; :code => true)
  #   => "&#8364;12.45 <span class=\"currency_code\">EUR</span>"
  attr_accessor :html

  # A template string used to format a money value.
  # Defaults to:
  # 
  #   '#{code}#{code && " "}#{symbol}#{sign}#{whole}#{fraction}#{time && " "}#{time}'
  attr_accessor :template
  
  # Set the decimal_places
  # Defaults to: nil
  attr_accessor :decimals

  # If passed true, formats for an input field (i.e.: as a number).
  def as_input_value=(x)
    if x
      self.thousands_separator = ''
      self.decimal_separator = '.'
      self.thousands = false
      self.cents = true
      self.symbol = false
      self.code = false
      self.html = false
      self.time = false
      self.time_fractional_digits = nil
    end
    x
  end


  @@default = nil
  # Get the default Formatter.
  def self.default
    @@default || self.new
  end


  # Set the default Formatter.
  def self.default=(x)
    @@default = x
  end
  

  def initialize(opt = { })
    @thousands_separator = ','
    @decimal_separator = '.'
    @thousands = true
    @cents = true
    @symbol = true
    @code = false
    @html = false
    @time = false
    @time_fractional_digits = 4
    @template = '#{code}#{code && " "}#{symbol}#{sign}#{whole}#{fraction}#{time && " "}#{time}'
    @template_object = nil
    @decimals = nil

    opt.each_pair{ | k, v | self.send("#{k}=", v) }
  end


  def currency=(x) # :nodoc:
    # DO NOTHING!
  end


  # Sets the template and the Template#template.
  def template=(x)
    if @template_object
      @template_object.template = x
    end
    @template = x
  end


  # Returns the Template object.
  def template_object
    return @template_object if @template_object

    @template_object = Template.new
    @template_object.template = @template if @template
    # $stderr.puts "template.template = #{@template_object.template.inspect}"
    @template_object.template_proc # pre-cache before clone.

    @template_object
  end


  def _format(m, currency = nil, time = nil) # :nodoc:
    # Get currency.
    currency ||= m.currency

    # Get time.
    time ||= m.time
    
    # set decimal places
    @decimals ||= currency.scale_exp

    # Setup template
    tmpl = self.template_object.clone
    # $stderr.puts "template.template = #{tmpl.template.inspect}"
    tmpl.money = m
    tmpl.currency = currency

    # Get scaled integer representation for this Currency.
    # $stderr.puts "m.currency = #{m.currency}, currency => #{currency}"
    x = m.Money_rep(currency)

    # Remove sign.
    x = - x if ( neg = x < 0 )
    tmpl.sign = neg ? '-' : nil
    
    # Convert to String.
    x = x.to_s
    
    # Keep prefixing "0" until filled to scale.
    while ( x.length <= currency.scale_exp )
      x = "0" + x
    end
    
    # Insert decimal place.
    whole = x[0 .. currency.format_left]
    fraction = x[currency.format_right .. -1]
    
    # Round the fraction to the supplied number of decimal places
    fraction = (fraction.to_f / currency.scale).round(@decimals).to_s[2..-1]
    # raise "decimals: #{@decimals}, scale_exp: #{currency.scale_exp}, x is: #{x.inspect}, currency.scale_exp is #{currency.scale_exp.inspect}, fraction: #{fraction.inspect}"
    while ( fraction.length < @decimals )
      fraction = fraction + "0" 
    end
    
    
    # raise "x is: #{x.inspect}, currency.scale_exp is #{currency.scale_exp.inspect}, fraction: #{fraction.inspect}"
    # fraction = ((fraction.to_f / currency.scale).round(decimals) * (10 ** decimals)).to_i.to_s
    
    # Do thousands.
    x = whole
    if @thousands && (@thousands_separator && ! @thousands_separator.empty?)
      x.reverse!
      x.gsub!(/(\d\d\d)/) {|y| y + @thousands_separator}
      x.sub!(/#{@thousands_separator}$/,'')
      x.reverse!
    end
    
    # Put whole and fractional parts.
    tmpl.whole = x
    tmpl.fraction = @cents && @decimal_separator ? @decimal_separator + fraction : nil

 
    # Add symbol?
    tmpl.symbol = @symbol ? ((@html && currency.symbol_html) || currency.symbol) : nil

    
    # Add currency code.
    tmpl.code = @code ? _format_Currency(currency) : nil

    # Add time.
    tmpl.time = @time && time ? _format_Time(time) : nil
    
    # Ask template to format the components.
    tmpl.format
  end


  def _format_Currency(c) # :nodoc:
    x = ''
    x << '<span class="currency_code">' if @html
    x << c.code.to_s
    x << '</span>' if @html
    x
  end


  def _format_Time(t) # :nodoc:
    x = ''
    x << t.getutc.xmlschema(@time_fractional_digits) if t
    x
  end


  @@empty_hash = { }
  @@empty_hash.freeze

  # Format a Money object as a String.
  # 
  #   m = Money.new("1234567.89")
  #   m.to_s(:code => true, :symbol => false)
  #     => "1,234,567.89 USD"
  #
  def format(m, opt = @@empty_hash)
    # raise "huh: #{opt.inspect}"
    
    fmt = self

    unless opt.empty? 
      fmt = fmt.clone
      opt.each_pair{ | k, v | fmt.send("#{k}=", v) }
    end

    # $stderr.puts "format(opt = #{opt.inspect})"
    fmt._format(m, opt[:currency]) # Allow override of current currency.
  end

end # class

