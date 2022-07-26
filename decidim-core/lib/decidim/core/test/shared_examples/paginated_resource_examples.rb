# frozen_string_literal: true

shared_examples "a paginated resource" do
  let(:collection_size) { 30 }

  before do
    visit_component
  end

  it "lists 10 resources per page by default" do
    expect(page).to have_css(resource_selector, count: 10)
    expect(page).to have_css("[data-pages] [data-page]", count: 3)
  end

  it "results per page can be changed from the selector" do
    expect(page).to have_css("[data-pagination]")

    within "[data-pagination]" do
      page.find("summary", text: "10").click
      click_link "50"
    end

    sleep 2
    expect(page).to have_css(resource_selector, count: collection_size)
    expect(page).to have_no_css("[data-pagination]")
  end
end
