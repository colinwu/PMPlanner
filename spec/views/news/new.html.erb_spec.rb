require 'rails_helper'

RSpec.describe "news/new", type: :view do
  before(:each) do
    assign(:news, News.new(
      :note => "MyText",
      :deactiv => "MyString",
      :urgent => false
    ))
  end

  it "renders new news form" do
    render

    assert_select "form[action=?][method=?]", news_index_path, "post" do

      assert_select "textarea#news_note[name=?]", "news[note]"

      assert_select "input#news_deactiv[name=?]", "news[deactiv]"

      assert_select "input#news_urgent[name=?]", "news[urgent]"
    end
  end
end
