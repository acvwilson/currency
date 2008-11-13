# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'currency/exchange'

# Represents a convertion rate between two currencies at a given period of time.
class Currency::Exchange::Rate
    # The first Currency.
    attr_reader :c1

    # The second Currency.
    attr_reader :c2

    # The rate between c1 and c2.
    #
    # To convert between m1 in c1 and m2 in c2:
    #
    #   m2 = m1 * rate.
    attr_reader :rate

    # The source of the rate.
    attr_reader :source

    # The Time of the rate.
    attr_reader :date

    # If the rate is derived from other rates, this describes from where it was derived.
    attr_reader :derived

    # Average rate over rate samples in a time range.
    attr_reader :rate_avg
    
    # Number of rate samples used to calcuate _rate_avg_.
    attr_reader :rate_samples

    # The rate low between date_0 and date_1.
    attr_reader :rate_lo

    # The rate high between date_0 and date_1.
    attr_reader :rate_hi

    # The rate at date_0.
    attr_reader :rate_date_0
 
    # The rate at date_1.
    attr_reader :rate_date_1
    
    # The lowest date of sampled rates.
    attr_reader :date_0
    
    # The highest date of sampled rates.
    # This is non-inclusive during searches to allow seamless tileings of 
    # time with rate buckets.
    attr_reader :date_1

    def initialize(c1, c2, c1_to_c2_rate, source = "UNKNOWN", date = nil, derived = nil, reciprocal = nil, opts = nil)
      @c1 = c1
      @c2 = c2
      @rate = c1_to_c2_rate
      raise ::Currency::Exception::InvalidRate, 
      [ 
       "rate is not positive",
       :rate, @rate,
       :c1, c1,
       :c2, c2,
      ] unless @rate && @rate >= 0.0
      @source = source
      @date = date
      @derived = derived
      @reciprocal = reciprocal
      
      #
      @rate_avg =
        @rate_samples =
        @rate_lo =
        @rate_hi =
        @rate_date_0 =
        @rate_date_1 =
        @date_0 =
        @date_1 =
        nil

      if opts
        opts.each_pair do | k, v |
          self.instance_variable_set("@#{k}", v)
        end
      end
    end


    # Returns a cached reciprocal Rate object from c2 to c1.
    def reciprocal
      @reciprocal ||= @rate == 1.0 ? self :
        self.class.new(@c2, @c1, 
                       1.0 / @rate, 
                       @source, 
                       @date, 
                       "reciprocal(#{derived || "#{c1.code}#{c2.code}"})", self,
                       { 
                         :rate_avg     => @rate_avg    && 1.0 / @rate_avg,
                         :rate_samples => @rate_samples,                            
                         :rate_lo      => @rate_lo     && 1.0 / @rate_lo,
                         :rate_hi      => @rate_hi     && 1.0 / @rate_hi,
                         :rate_date_0  => @rate_date_0 && 1.0 / @rate_date_0,
                         :rate_date_1  => @rate_date_1 && 1.0 / @rate_date_1,
                         :date_0       => @date_0,
                         :date_1       => @date_1,
                       }
                       )
    end


    # Converts from _m_ in Currency _c1_ to the opposite currency.
    def convert(m, c1)
      m = m.to_f	
      if @c1 == c1
        # $stderr.puts "Converting #{@c1} #{m} to #{@c2} #{m * @rate} using #{@rate}"
        m * @rate
      else
        # $stderr.puts "Converting #{@c2} #{m} to #{@c1} #{m / @rate} using #{1.0 / @rate}; recip"
        m / @rate
      end
    end


    # Collect rate samples into rate_avg, rate_hi, rate_lo, rate_date_0, rate_date_1, date_0, date_1.
    def collect_rates(rates)
      rates = [ rates ] unless rates.kind_of?(Enumerable)
      rates.each do | r |
        collect_rate(r)
      end
      self
    end

    # Collect rates samples in to this Rate.
    def collect_rate(rate)
      # Initial.
      @rate_samples ||= 0
      @rate_sum ||= 0
      @source ||= rate.source
      @c1 ||= rate.c1
      @c2 ||= rate.c2
 
      # Reciprocal?
      if @c1 == rate.c2 && @c2 == rate.c1
        collect_rate(rate.reciprocal)
      elsif ! (@c1 == rate.c1 && @c2 == rate.c2)
        raise ::Currency::Exception::InvalidRate,
        [ 
         "Cannot collect rates between different currency pairs",
          :rate1, self,
          :rate2, rate,
        ]
      else
        # Multisource?
        @source = "<<multiple-sources>>" unless @source == rate.source

        # Calculate rate average.
        @rate_samples += 1
        @rate_sum += rate.rate || (rate.rate_lo + rate.rate_hi) * 0.5
        @rate_avg = @rate_sum / @rate_samples

        # Calculate rates ranges.
        r = rate.rate_lo || rate.rate
        unless @rate_lo && @rate_lo < r
          @rate_lo = r
        end
        r = rate.rate_hi || rate.rate
        unless @rate_hi && @rate_hi > r
          @rate_hi = r
        end

        # Calculate rates on date range boundaries
        r = rate.rate_date_0 || rate.rate
        d = rate.date_0 || rate.date
        unless @date_0 && @date_0 < d
          @date_0 = d
          @rate_date_0 = r
        end

        r = rate.rate_date_1 || rate.rate
        d = rate.date_1 || rate.date
        unless @date_1 && @date_1 > d
          @date_1 = d 
          @rate_date_1 = r
        end

        @date ||= rate.date || rate.date0 || rate.date1
      end
      self
    end


    def to_s(extended = false)
      extended = "#{date_0} #{rate_date_0} |< #{rate_lo} #{rate} #{rate_hi} >| #{rate_date_1} #{date_1}" if extended
      extended ||= ''
      "#<#{self.class.name} #{c1.code} #{c2.code} #{rate} #{source.inspect} #{date ? date.strftime('%Y/%m/%d-%H:%M:%S') : 'nil'} #{derived && derived.inspect} #{extended}>"
    end

    def inspect; to_s; end

end # class


class Currency::Exchange::Rate::Writable < Currency::Exchange::Rate
  attr_writer :source
  attr_writer :derived
  attr_writer :rate
  def initialize(c1 = nil, c2 = nil, rate = nil, *opts)
    super(c1, c2, 0.0, *opts)
    @rate = rate
  end
end # class

