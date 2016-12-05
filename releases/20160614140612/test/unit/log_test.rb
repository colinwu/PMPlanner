require 'test_helper'

class LogTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Log.new.valid?
  end
end
