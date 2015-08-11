require 'test_helper'

class PreferenceTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Preference.new.valid?
  end
end
