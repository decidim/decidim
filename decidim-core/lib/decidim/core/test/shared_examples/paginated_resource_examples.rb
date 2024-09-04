# frozen_string_literal: true

shared_examples "a paginated resource" do
  let(:collection_size) { 50 }

  before do
    visit_component
  end

  it "lists 25 resources per page by default" do
    expect(page).to have_css(resource_selector, count: 25)
    expect(page).to have_css("[data-pages] [data-page]", count: 2)
  end

  it "results per page can be changed from the selector" do
    expect(page).to have_css("[data-pagination]")

    within "[data-pagination]" do
      page.find("summary", text: "25").click
      click_link "50"
    end

    sleep 2
    expect(page).to have_css(resource_selector, count: collection_size)
    expect(page).not_to have_css("[data-pagination]")
  end
end
