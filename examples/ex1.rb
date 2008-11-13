$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'currency'
require 'currency/exchange/rate/source/test'

x = Currency.Money("1,203.43", :USD)

puts x.to_s
puts (x * 10).to_s
puts (x * 33333).inspect

puts x.currency.code.inspect

