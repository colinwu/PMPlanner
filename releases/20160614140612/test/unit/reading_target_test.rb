require 'test_helper'

class ReadingTargetTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert ReadingTarget.new.valid?
  end
end
