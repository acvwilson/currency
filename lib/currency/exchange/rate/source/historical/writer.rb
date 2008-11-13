
require 'currency/exchange/rate/source/historical'

# Responsible for writing historical rates from a rate source.
class Currency::Exchange::Rate::Source::Historical::Writer

  # Error during handling of historical rates.
  class Error < ::Currency::Exception::Base; end

  # The source of rates.
  attr_accessor :source

  # If true, compute all Rates between rates.
  # This can be used to aid complex join reports that may assume
  # c1 as the from currency and c2 as the to currency.
  attr_accessor :all_rates

  # If true, store identity rates.
  # This can be used to aid complex join reports.
  attr_accessor :identity_rates

  # If true, compute and store all reciprocal rates.
  attr_accessor :reciprocal_rates

  # If set, a set of preferred currencies.
  attr_accessor :preferred_currencies

  # If set, a list of required currencies.
  attr_accessor :required_currencies

  # If set, a list of required base currencies.
  # base currencies must have rates as c1.
  attr_accessor :base_currencies

  # If set, use this time quantitizer to
  # manipulate the Rate date_0 date_1 time ranges.
  # If :default, use the TimeQuantitizer.default.
  attr_accessor :time_quantitizer


  def initialize(opt = { })
    @all_rates = true
    @identity_rates = false
    @reciprocal_rates = true
    @preferred_currencies = nil
    @required_currencies = nil
    @base_currencies = nil
    @time_quantitizer = nil
    opt.each_pair{| k, v | self.send("#{k}=", v) }
  end


  # Returns a list of selected rates from source.
  def selected_rates
    # Produce a list of all currencies.
    currencies = source.currencies

    # $stderr.puts "currencies = #{currencies.join(', ')}"

    selected_rates = [ ]

    # Get list of preferred_currencies.
    if self.preferred_currencies
      self.preferred_currencies = self.preferred_currencies.collect do | c | 
        ::Currency::Currency.get(c) 
      end
      currencies = currencies.select do | c | 
        self.preferred_currencies.include?(c)
      end.uniq
    end


    # Check for required currencies.
    if self.required_currencies
      self.required_currencies = self.required_currencies.collect do | c |
        ::Currency::Currency.get(c) 
      end

      self.required_currencies.each do | c |
        unless currencies.include?(c)
          raise ::Currency::Exception::MissingCurrency, 
          [ 
           "Required currency #{c.inspect} not in #{currencies.inspect}", 
           :currency, c, 
           :required_currency, currencies,
          ]
        end
      end
    end


    # $stderr.puts "currencies = #{currencies.inspect}"

    deriver = ::Currency::Exchange::Rate::Deriver.new(:source => source)

    # Produce Rates for all pairs of currencies.
    if all_rates
      currencies.each do | c1 |
        currencies.each do | c2 |
          next if c1 == c2 && ! identity_rates
           rate = deriver.rate(c1, c2, nil)
          selected_rates << rate unless selected_rates.include?(rate)
        end
      end
    elsif base_currencies
      base_currencies.each do | c1 |
        c1 = ::Currency::Currency.get(c1)
        currencies.each do | c2 |
          next if c1 == c2 && ! identity_rates
          rate = deriver.rate(c1, c2, nil)
          selected_rates << rate unless selected_rates.include?(rate)
        end
      end
    else
      selected_rates = source.rates.select do | r |
        next if r.c1 == r.c2 && ! identity_rates
        currencies.include?(r.c1) && currencies.include?(r.c2)
      end
    end

    if identity_rates
      currencies.each do | c1 |
        c1 = ::Currency::Currency.get(c1)
        c2 = c1
        rate = deriver.rate(c1, c2, nil)
        selected_rates << rate unless selected_rates.include?(rate)
      end
    else
      selected_rates = selected_rates.select do | r |
        r.c1 != r.c2
      end
    end

    if reciprocal_rates
      selected_rates.clone.each do | r |
        c1 = r.c2
        c2 = r.c1
        rate = deriver.rate(c1, c2, nil)
        selected_rates << rate unless selected_rates.include?(rate)
      end
    end

    # $stderr.puts "selected_rates = #{selected_rates.inspect}\n [#{selected_rates.size}]"

    selected_rates
  end


  # Returns an Array of Historical::Rate objects that were written.
  # Avoids writing Rates that already have been written.
  def write_rates(rates = selected_rates)
 
    # Create Historical::Rate objects.
    h_rate_class = ::Currency::Exchange::Rate::Source::Historical::Rate

    # Most Rates from the same Source will probably have the same time,
    # so cache the computed date_range.
    date_range_cache = { } 
    rate_0 = nil
    if time_quantitizer = self.time_quantitizer
      time_quantitizer = ::Currency::Exchange::TimeQuantitizer.current if time_quantitizer == :current
    end

    h_rates = rates.collect do | r |
      rr = h_rate_class.new.from_rate(r)
      rr.dates_to_localtime!

      if rr.date && time_quantitizer
        date_range = date_range_cache[rr.date] ||= time_quantitizer.quantitize_time_range(rr.date)
        rr.date_0 = date_range.begin
        rr.date_1 = date_range.end
      end

      rate_0 ||= rr if rr.date_0 && rr.date_1

      rr
    end

    # Fix any dateless Rates.
    if rate_0
      h_rates.each do | rr |
        rr.date_0 = rate_0.date_0 unless rr.date_0
        rr.date_1 = rate_0.date_1 unless rr.date_1
      end
    end

    # Save them all or none.
    stored_h_rates = [ ] 
    h_rate_class.transaction do 
      h_rates.each do | rr |
        # Skip identity rates.
        next if rr.c1 == rr.c2 && ! identity_rates

        # Skip if already exists.
        existing_rate = rr.find_matching_this(:first)
        if existing_rate
          stored_h_rates << existing_rate # Already existed.
        else
          begin
            rr.save!
          rescue Object => err
            raise ::Currency::Exception::Generic, 
            [ 
             "During save of #{rr.inspect}", 
             :error, err,
            ]
          end
          stored_h_rates << rr # Written.
        end
      end
    end

    # Return written Historical::Rates.
    stored_h_rates
  end

end # class



