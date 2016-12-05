require 'test_helper'

class OutstandingPmTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert OutstandingPm.new.valid?
  end
end
