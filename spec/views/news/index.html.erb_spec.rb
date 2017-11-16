require 'rails_helper'

RSpec.describe "news/index", type: :view do
  before(:each) do
    assign(:news, [
      News.create!(
        :note => "MyText",
        :deactiv => "Deactiv",
        :urgent => false
      ),
      News.create!(
        :note => "MyText",
        :deactiv => "Deactiv",
        :urgent => false
      )
    ])
  end

  it "renders a list of news" do
    render
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Deactiv".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
