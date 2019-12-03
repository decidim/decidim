# frozen_string_literal: true

shared_examples "a paginated collection" do
  before do
    visit current_path
  end

  describe "Number of results per page" do
    it "lists 15 resources per page by default" do
      expect(page).to have_css(".table-list tbody tr", count: 15)
    end

    it "changes the number of results per page" do
      within ".results-per-page__dropdown" do
        page.find("a", text: "15").click
        click_link "50"
      end

      expect(page).to have_selector(".table-list tbody tr", count: 50)
    end
  end
end
