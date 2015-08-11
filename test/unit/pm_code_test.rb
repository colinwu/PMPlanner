require 'test_helper'

class PMCodeTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert PMCode.new.valid?
  end
end
