require 'test_helper'

class ModelTargetTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert ModelTarget.new.valid?
  end
end
