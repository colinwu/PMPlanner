require 'test_helper'

class TechnicianTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Technician.new.valid?
  end
end
