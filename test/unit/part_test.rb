require 'test_helper'

class PartTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Part.new.valid?
  end
end
