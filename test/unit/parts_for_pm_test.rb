require 'test_helper'

class PartsForPmTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert PartsForPm.new.valid?
  end
end
