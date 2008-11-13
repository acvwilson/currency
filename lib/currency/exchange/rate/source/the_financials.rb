# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

require 'currency/exchange/rate/source/base'

require 'net/http'
require 'open-uri'
require 'rexml/document'


# Connects to http://www.thefinancials.com and parses XML.
#
# This is for demonstration purposes.
#
class Currency::Exchange::Rate::Source::TheFinancials < ::Currency::Exchange::Rate::Source::Provider
  # Defines the pivot currency for http://thefinancials.com/.
  PIVOT_CURRENCY = :USD
  
  def initialize(*opt)
    @raw_rates = nil
    self.uri_path = 'syndicated/UNKNOWN/fxrates.xml'
    super(*opt)
    self.uri = "http://www.thefinancials.com/#{self.uri_path}"
  end
  

  # Returns 'thefinancials.com'.
  def name
    'thefinancials.org'
  end


#  def get_page_content
#    test_content
#  end


  def clear_rates
    @raw_rates = nil
    super
  end
  

  def raw_rates
    rates
    @raw_rates
  end


  # Parses XML for rates.
  def parse_rates(data = nil)
    data = get_page_content unless data
    
    rates = [ ]

    @raw_rates = { }

    # $stderr.puts "parse_rates: data = #{data}"

    doc = REXML::Document.new(data).root
    doc.elements.to_a('//record').each do | record |
      c1_c2 = record.elements.to_a('symbol')[0].text
      md = /([A-Z][A-Z][A-Z]).*?([A-Z][A-Z][A-Z])/.match(c1_c2)
      c1, c2 = md[1], md[2]

      c1 = c1.upcase.intern
      c2 = c2.upcase.intern
      
      rate = record.elements.to_a('last')[0].text.to_f

      date = record.elements.to_a('date')[0].text
      date = Time.parse("#{date} 12:00:00 -05:00") # USA NY => EST

      rates << new_rate(c1, c2, rate, date)

      (@raw_rates[c1] ||= { })[c2] ||= rate
    end

    rates
  end
  
  
  # Return a list of known base rates.
  def load_rates(time = nil)
    self.date = time
    parse_rates
  end
  
 
  def test_content
    <<EOF
<?xml version="1.0" ?> 
<TFCRecords>
<record>
<symbol>USD/EUR</symbol> 
<date>10/25/2001</date> 
<last>1.115822</last> 
</record>
<record>
<symbol>USD/AUD</symbol> 
<date>10/25/2001</date> 
<last>1.975114</last> 
</record>
<record>
<symbol>USD/CAD</symbol> 
<date>10/25/2001</date> 
<last>1.57775</last> 
</record>
<record>
<symbol>USD/CNY</symbol> 
<date>10/25/2001</date> 
<last>8.2769</last> 
</record>
<record>
<symbol>USD/ESP</symbol> 
<date>10/25/2001</date> 
<last>185.65725</last> 
</record>
<record>
<symbol>USD/GBP</symbol> 
<date>10/25/2001</date> 
<last>0.698849867830019</last> 
</record>
<record>
<symbol>USD/HKD</symbol> 
<date>10/25/2001</date> 
<last>7.7999</last> 
</record>
<record>
<symbol>USD/IDR</symbol> 
<date>10/25/2001</date> 
<last>10265</last> 
</record>
<record>
<symbol>USD/INR</symbol> 
<date>10/25/2001</date> 
<last>48.01</last> 
</record>
<record>
<symbol>USD/JPY</symbol> 
<date>10/25/2001</date> 
<last>122.68</last> 
</record>
<record>
<symbol>USD/KRW</symbol> 
<date>10/25/2001</date> 
<last>1293.5</last> 
</record>
<record>
<symbol>USD/MYR</symbol> 
<date>10/25/2001</date> 
<last>3.8</last> 
</record>
<record>
<symbol>USD/NZD</symbol> 
<date>10/25/2001</date> 
<last>2.41485</last> 
</record>
<record>
<symbol>USD/PHP</symbol> 
<date>10/25/2001</date> 
<last>52.05</last> 
</record>
<record>
<symbol>USD/PKR</symbol> 
<date>10/25/2001</date> 
<last>61.6</last> 
</record>
<record>
<symbol>USD/SGD</symbol> 
<date>10/25/2001</date> 
<last>1.82615</last> 
</record>
<record>
<symbol>USD/THB</symbol> 
<date>10/25/2001</date> 
<last>44.88</last> 
</record>
<record>
<symbol>USD/TWD</symbol> 
<date>10/25/2001</date> 
<last>34.54</last> 
</record>
</TFCRecords>
EOF
  end

end # class



