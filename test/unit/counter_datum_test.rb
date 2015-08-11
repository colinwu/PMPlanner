require 'test_helper'

class CounterDatumTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert CounterDatum.new.valid?
  end
end
