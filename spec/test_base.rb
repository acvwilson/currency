# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.

# Base Test class

require 'test/unit'
require 'currency'
require 'currency/exchange/rate/source/test'

module Currency

class TestBase < Test::Unit::TestCase
  def setup
    super
    @rate_source ||= get_rate_source
    Exchange::Rate::Source.default = @rate_source

    # Force non-historical money values.
    Money.default_time = nil
  end


  def get_rate_source
    source = Exchange::Rate::Source::Test.instance
    deriver = Exchange::Rate::Deriver.new(:source => source)
  end

  # Avoid "No test were specified" error.
  def test_foo
    assert true
  end


  # Helpers.
  def assert_equal_float(x, y, eps = 1.0e-8)
    d = (x * eps).abs
    assert((x - d) <= y)
    assert(y <= (x + d))
  end

end # class

end # module

