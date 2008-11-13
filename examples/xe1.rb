$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'currency'
require 'currency/exchange/rate/source/xe'

ex = Currency::Exchange::Rate::Source::Xe.new()
Currency::Exchange::Rate::Source.current = ex

puts ex.inspect
puts ex.parse_page_rates.inspect

usd = Currency.Money("1", 'USD')

puts "usd = #{usd}"

cad = usd.convert(:CAD)
puts "cad = #{cad}"



