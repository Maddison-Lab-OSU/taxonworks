require 'spec_helper'

describe "public_contents/index" do
  before(:each) do
    assign(:public_contents, [
      stub_model(PublicContent,
        :otu_id => 1,
        :topic_id => 2,
        :text => "MyText",
        :project_id => 3,
        :created_by_id => 4,
        :updated_by_id => 5,
        :content_id => 6
      ),
      stub_model(PublicContent,
        :otu_id => 1,
        :topic_id => 2,
        :text => "MyText",
        :project_id => 3,
        :created_by_id => 4,
        :updated_by_id => 5,
        :content_id => 6
      )
    ])
  end

  it "renders a list of public_contents" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
  end
end
