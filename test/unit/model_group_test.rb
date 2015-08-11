require 'test_helper'

class ModelGroupTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert ModelGroup.new.valid?
  end
end
