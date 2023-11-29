# frozen_string_literal: true

require "spec_helper"

describe "sortitions" do
  include_context "with a component"

  let(:manifest_name) { "sortitions" }
  let!(:user) { create(:user, :confirmed, organization: participatory_process.organization) }

  context "when there are no sortitions" do
    it "shows an empty page with a message" do
      visit_component

      within "main" do
        expect(page).to have_content("There are no sortitions yet.")
      end
    end
  end

  context "when listing sortitions in a participatory process" do
    it "lists all the sortitions" do
      create_list(:sortition, 3, component:)
      visit_component
      expect(page).to have_css(".card__list", count: 3)
    end

    context "when order by 'random'" do
      let!(:lucky_sortition) { create(:sortition, component:) }
      let!(:unlucky_sortition) { create(:sortition, component:) }

      it "lists the sortitions ordered randomly" do
        page.visit "#{main_component_path(component)}?order=random"

        expect(page).to have_selector(".card__list", count: 2)
        expect(page).to have_selector(".card__list", text: lucky_sortition.title[:en])
        expect(page).to have_selector(".card__list", text: unlucky_sortition.title[:en])
      end
    end

    context "when ordering by 'recent'" do
      it "lists the sortitions ordered by created at" do
        older = create(:sortition, component:, created_at: 1.month.ago)
        recent = create(:sortition, component:)

        visit_component

        expect(page).to have_selector(".order-by .button:first-child", text: recent.title[:en])
        expect(page).to have_selector(".order-by .button:last-child", text: older.title[:en])
      end
    end

    context "when paginating" do
      let!(:collection) { create_list(:sortition, collection_size, component:) }
      let!(:resource_selector) { ".card__list" }

      it_behaves_like "a paginated resource"
    end
  end

  describe "filters" do
    context "when filtering by text" do
      it "updates the current URL" do
        create(:sortition, component:, title: { en: "Foobar sortition" })
        create(:sortition, component:, title: { en: "Another sortition" })
        visit_component

        within "form.new_filter" do
          fill_in("filter[search_text_cont]", with: "foobar")
          within "div.filter-search" do
            click_button
          end
        end

        expect(page).not_to have_content("Another sortition")
        expect(page).to have_content("Foobar sortition")

        filter_params = CGI.parse(URI.parse(page.current_url).query)
        expect(filter_params["filter[search_text_cont]"]).to eq(["foobar"])
      end
    end
  end
end
