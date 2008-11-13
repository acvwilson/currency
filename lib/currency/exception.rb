# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

module Currency::Exception
    # Base class for all Currency::Exception objects.
    #
    #   raise Currency::Exception [ "msg", :opt1, 1, :opt2, 2 ]
    #
    class Base < ::Exception
      EMPTY_HASH = { }.freeze

      def initialize(arg1, *args)
        case arg1
        # [ description, ... ]
        when Array
          @opts = arg1
          arg1 = arg1.shift
        else
          @opts = nil
        end

        case @opts
        when Array
          if @opts.size == 1 && @opts.first.kind_of?(Hash)
            # [ description, { ... } ]
            @opts = @opts.first
          else
            # [ description, :key, value, ... ]
            @opts = Hash[*@opts]
          end
        end

        case @opts
        when Hash
          @opts = @opts.dup.freeze
        else
          @opts = { :info => @opts }.freeze
        end

        @opts ||= EMPTY_HASH

        super(arg1, *args)
      end


      def method_missing(sel, *args, &blk)
        sel = sel.to_sym
        if args.empty? && ! block_given? && @opts.key?(sel) 
          return @opts[sel]
        end
        super
      end

      def to_s
        super + ": #{@opts.inspect}"
      end

    end

    # Generic Error.
    class Generic < Base
    end

    # Error during parsing of Money values from String.
    class InvalidMoneyString < Base
    end

    # Error during coercion of external Money values.
    class InvalidMoneyValue < Base
    end
  
    # Error in Currency code formeat.
    class InvalidCurrencyCode < Base
    end
    
    # Error during conversion between currencies.
    class IncompatibleCurrency < Base
    end

    # Error during locating currencies.
    class MissingCurrency < Base
    end

    # Error if an Exchange is not defined.
    class UndefinedExchange < Base
    end

    # Error if a Currency is unknown.
    class UnknownCurrency < Base
    end

    # Error if an Exchange Rate Source cannot provide an Exchange::Rate.
    class UnknownRate < Base
    end

    # Error if an Exchange Rate Source.
    class RateSourceError < Base
    end

    # Error if an Exchange Rate Source cannot supply any rates.
    class UnavailableRates < Base
    end

    # Error if an Exchange::Rate is not valid.
    class InvalidRate < Base
    end
    
    # Error if a subclass is responsible for implementing a method.
    class SubclassResponsibility < Base
    end

    # Error if some functionality is unimplemented
    class Unimplemented < Base
    end
  
    # Error if reentrantancy is d
    class InvalidReentrancy < Base
    end
end # module
