require 'rails_helper'

RSpec.describe "news/show", type: :view do
  before(:each) do
    @news = assign(:news, News.create!(
      :note => "MyText",
      :deactiv => "Deactiv",
      :urgent => false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Deactiv/)
    expect(rendered).to match(/false/)
  end
end
