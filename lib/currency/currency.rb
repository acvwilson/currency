# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.


# Represents a currency.
#
# Currency objects are created on-demand by Currency::Currency::Factory.
#
# See Currency.get method.
#
class Currency::Currency
    # Returns the ISO three-letter currency code as a symbol.
    # e.g. :USD, :CAD, etc.
    attr_reader :code

    # The Currency's scale factor.  
    # e.g: the :USD scale factor is 100.
    attr_reader :scale

    # The Currency's scale factor.  
    # e.g: the :USD scale factor is 2, where 10 ^ 2 == 100.
    attr_reader :scale_exp

    # Used by Formatter.
    attr_reader :format_right

    # Used by Formatter.
    attr_reader :format_left

    # The Currency's symbol. 
    # e.g: USD symbol is '$'
    attr_accessor :symbol

    # The Currency's symbol as HTML.
    # e.g: EUR symbol is '&#8364;' (:html &#8364; :) or '&euro;' (:html &euro; :)
    attr_accessor :symbol_html

    # The default Formatter.
    attr_accessor :formatter

    # The default parser.
    attr_accessor :parser


    # Create a new currency.
    # This should only be called from Currency::Currency::Factory.
    def initialize(code, symbol = nil, scale = 1000000)
      self.code = code
      self.symbol = symbol
      self.scale = scale

      @formatter =
        @parser = 
        nil
    end


    # Returns the Currency object from the default Currency::Currency::Factory
    # by its three-letter uppercase Symbol, such as :USD, or :CAD.
    def self.get(code)
      # $stderr.puts "#{self}.get(#{code.inspect})"
      return nil unless code
      return code if code.kind_of?(::Currency::Currency)
      Factory.default.get_by_code(code)
    end


    # Internal method for converting currency codes to internal
    # Symbol format.
    def self.cast_code(x)
      x = x.upcase.intern if x.kind_of?(String)
      raise ::Currency::Exception::InvalidCurrencyCode, x unless x.kind_of?(Symbol)
      raise ::Currency::Exception::InvalidCurrencyCode, x unless x.to_s.length == 3
      x
    end


    # Returns the hash of the Currency's code.
    def hash
      @code.hash
    end


    # Returns true if the Currency's are equal.
    def eql?(x)
      self.class == x.class && @code == x.code
    end


    # Returns true if the Currency's are equal.
    def ==(x)
      self.class == x.class && @code == x.code
    end


    # Clients should never call this directly.
    def code=(x)
      x = self.class.cast_code(x) unless x.nil?
      @code = x
      #$stderr.puts "#{self}.code = #{@code}"; x
    end


    # Clients should never call this directly.
    def scale=(x)
      @scale = x
      return x if x.nil?
      @scale_exp = Integer(Math.log10(@scale));
      @format_right = - @scale_exp
      @format_left = @format_right - 1
      x
    end


    # Parse a Money string in this Currency.
    #
    # See Currency::Parser#parse.
    #
    def parse(str, *opt)
      parser_or_default.parse(str, *opt)
    end


    def parser_or_default
      (@parser || ::Currency::Parser.default)
    end


    # Formats the Money value as a string using the current Formatter.
    # See Currency::Formatter#format.
    def format(m, *opt)
      formatter_or_default.format(m, *opt)
    end


    def formatter_or_default
      (@formatter || ::Currency::Formatter.default)
    end


    # Returns the Currency code as a String.
    def to_s
      @code.to_s
    end


    # Returns the default Factory's currency.
    def self.default
      Factory.default.currency
    end


    # Sets the default Factory's currency.
    def self.default=(x)
      x = self.get(x) unless x.kind_of?(self)
      Factory.default.currency = x
    end


    # If selector is [A-Z][A-Z][A-Z], load the currency via Factory.default.
    #
    #   Currency::Currency.USD
    #   => #<Currency::Currency:0xb7d0917c @formatter=nil, @scale_exp=2, @scale=100, @symbol="$", @format_left=-3, @code=:USD, @parser=nil, @format_right=-2>
    #
    def self.method_missing(sel, *args, &blk)
      if args.size == 0 && (! block_given?) && /^[A-Z][A-Z][A-Z]$/.match(sel.to_s)
        Factory.default.get_by_code(sel)
      else
        super
      end
    end

end # class
  

