require 'rails_helper'

RSpec.describe "news/edit", type: :view do
  before(:each) do
    @news = assign(:news, News.create!(
      :note => "MyText",
      :deactiv => "MyString",
      :urgent => false
    ))
  end

  it "renders the edit news form" do
    render

    assert_select "form[action=?][method=?]", news_path(@news), "post" do

      assert_select "textarea#news_note[name=?]", "news[note]"

      assert_select "input#news_deactiv[name=?]", "news[deactiv]"

      assert_select "input#news_urgent[name=?]", "news[urgent]"
    end
  end
end
