# frozen_string_literal: true

shared_examples "a paginated resource" do
  let(:collection_size) { 30 }

  before do
    visit_feature
  end

  it "lists 20 resources per page by default" do
    expect(page).to have_css(resource_selector, count: 20)
    expect(page).to have_css(".pagination .page", count: 2)
  end

  it "results per page can be changed from the selector" do
    expect(page).to have_css(".results-per-page")

    within ".results-per-page" do
      page.find("a", text: "20").click
      click_link "50"
    end

    expect(page).to have_css(resource_selector, count: collection_size)
    expect(page).to have_no_css(".pagination")
  end
end
