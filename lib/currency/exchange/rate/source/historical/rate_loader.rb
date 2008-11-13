require 'currency/exchange/rate/source/historical'
require 'currency/exchange/rate/source/historical/rate'
require 'currency/exchange/rate/source/historical/writer'


# Currency::Config.current.historical_table_name = 'currency_rates'
# opts['uri_path'] ||= 'syndicated/cnusa/fxrates.xml'

# Loads rates from multiple sources and will store them
# as historical rates in a database.

class ::Currency::Exchange::Rate::Source::Historical::RateLoader
  attr_accessor :options
  attr_accessor :source_options
  attr_accessor :required_currencies
  attr_accessor :rate_sources
  attr_accessor :rate_source_options
  attr_accessor :verbose
  attr_accessor :preferred_summary_source
  attr_accessor :base_currencies
  attr_accessor :summary_rate_src
  attr_reader   :writer

  def initialize(opts = { })
    self.summary_rate_src = 'summary'
    self.source_options = { }
    self.options = opts.dup.freeze
    self.base_currencies = [ :USD ]
    self.required_currencies =
      [
       :USD,
       :GBP,
       :CAD,
       :EUR,
       #   :MXP,
      ]
    self.verbose = ! ! ENV['CURRENCY_VERBOSE']
    opts.each do | k, v | 
      setter = "#{k}="
      send(setter, v) if respond_to?(setter)
    end
  end


  def initialize_writer(writer = Currency::Exchange::Rate::Source::Historical::Writer.new)
    @writer = writer

    writer.time_quantitizer = :current
    writer.required_currencies = required_currencies
    writer.base_currencies = base_currencies
    writer.preferred_currencies = writer.required_currencies
    writer.reciprocal_rates = true
    writer.all_rates = true
    writer.identity_rates = false 
 
    options.each do | k, v |
      setter = "#{k}="
      writer.send(setter, v) if writer.respond_to?(setter)
    end

    writer
  end


  def run
    rate_sources.each do | src |
      # Create a historical rate writer.
      initialize_writer

      # Handle creating a summary rates called 'summary'.
      if src == summary_rate_src
        summary_rates(src)
      else
        require "currency/exchange/rate/source/#{src}"
        src_cls_name = src.gsub(/(^|_)([a-z])/) { | m | $2.upcase }
        src_cls = Currency::Exchange::Rate::Source.const_get(src_cls_name)
        src = src_cls.new(source_options)
        
        writer.source = src  
        
        writer.write_rates
      end
    end
  ensure
    @writer = nil
  end


  def summary_rates(src)
    # A list of summary rates.
    summary_rates = [ ]
    
    # Get a list of all rate time ranges before today,
    # that do not have a 'cnu' summary rate.
    h_rate_cls = Currency::Exchange::Rate::Source::Historical::Rate
    conn = h_rate_cls.connection
    
    # Select only rates from yesterday or before back till 30 days.
    date_1 = Time.now - (0 * 24 * 60 * 60)
    date_0 = date_1 - (30 * 24 * 60 * 60)
    
    date_0 = conn.quote(date_0)
    date_1 = conn.quote(date_1)
    
    query = 
"SELECT 
  DISTINCT a.date_0, a.date_1 
FROM 
  #{h_rate_cls.table_name} AS a 
WHERE 
      a.source <> '#{src}' 
  AND a.date_1 >= #{date_0} AND a.date_1 < #{date_1} 
  AND (SELECT COUNT(b.id) FROM #{h_rate_cls.table_name} AS b 
       WHERE 
             b.c1 = a.c1 AND b.c2 = a.c2 
         AND b.date_0 = a.date_0 AND b.date_1 = a.date_1 
         AND b.source = '#{src}') = 0 
ORDER BY
   date_0"
    STDERR.puts "query = \n#{query.split("\n").join(' ')}" if verbose
      
    dates = conn.query(query)
      
    dates.each do | date_range |
      STDERR.puts "\n=============================================\n" if verbose
      STDERR.puts "date_range = #{date_range.inspect}"                if verbose
      
      # Query for all rates that have the same date range.
      q_rate = h_rate_cls.new(:date_0 => date_range[0], :date_1 => date_range[1])
      available_rates = q_rate.find_matching_this(:all)
      
      # Collect all the currency pairs and rates.
      currency_pair = { }
      available_rates.each do | h_rate |
        rate = h_rate.to_rate
        (currency_pair[ [ rate.c1, rate.c2 ] ] ||= [ ]) << [ h_rate, rate ]
        # STDERR.puts "rate = #{rate} #{h_rate.date_0} #{h_rate.date_1}" if verbose
      end
      
      currency_pair.each_pair do | currency_pair, rates |
        STDERR.puts "\n  =============================================\n" if verbose
        STDERR.puts "  currency_pair = #{currency_pair}"                  if verbose
        
        # Create a summary rate for the currency pair.
        selected_rates = [ ]
        
        rates.each do | h_rates |
          h_rate, rate = *h_rates
          
          # Sanity check!
          next if h_rate.source == src
          
          # Found perferred source?
          if h_rate.source == preferred_summary_source
            selected_rates = [ h_rates ]
            break
          end
          
          selected_rates << h_rates
        end
        
        unless selected_rates.empty?
          summary_rate = Currency::Exchange::Rate::Writable.new(currency_pair[0], currency_pair[1], 0.0)
          selected_rates.each do | h_rates |
            h_rate, rate = *h_rates
            STDERR.puts "    rate = #{rate.inspect}" if verbose
            summary_rate.collect_rate(rate)
          end
          
          # Save the rate.
          summary_rate.rate = summary_rate.rate_avg
          summary_rate.source = src
          summary_rate.derived = 'summary(' + selected_rates.collect{|r| r[0].id}.sort.join(',') + ')'
          STDERR.puts "  summary_rate = #{summary_rate} #{summary_rate.rate_samples}" if verbose
          
          summary_rates << summary_rate
        end
      end
    end
    
    writer.write_rates(summary_rates)
  end
  
end


