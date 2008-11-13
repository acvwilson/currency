# Copyright (C) 2006-2007 Kurt Stephens <ruby-currency(at)umleta.com>
# See LICENSE.txt for details.


require 'test/test_base'
require 'currency'

module Currency

class ConfigTest < TestBase
  def setup
    super
  end

  ############################################
  # Simple stuff.
  #

  def test_config
    assert_kind_of Money, m = Money.new(1.999)
    assert_equal 199, m.rep

    Config.configure do | c |
      c.float_ref_filter = Proc.new { | x | x.round }

      assert_kind_of Money, m = Money.new(1.999)
      assert_equal 200, m.rep
    end

  end

end # class

end # module


