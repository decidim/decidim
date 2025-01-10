# frozen_string_literal: true

shared_examples "when managing results bulk actions as an admin" do
  context "when in the Results list page" do
    it "shows a checkbox to select each result" do
      expect(page).to have_css(".table-list tbody [data-result-checkbox]", count: 2)
    end

    it "shows a checkbox to (des)select all results" do
      expect(page).to have_css(".table-list thead [data-select-all]", count: 1)
    end

    context "when selecting results" do
      before do
        page.find_by_id("results_bulk").set(true)
      end

      it "shows the number of selected results" do
        expect(page).to have_css("span[data-selected-count]", count: 1)
      end

      it "shows the bulk actions button" do
        expect(page).to have_css("#js-bulk-actions-button", count: 1)
      end

      context "when click the bulk action button" do
        before do
          click_on "Actions"
        end

        it "shows the bulk actions dropdown" do
          expect(page).to have_css("#js-bulk-actions-dropdown", count: 1)
        end

        it "shows the change action options" do
          expect(page).to have_selector(:link_or_button, "Change taxonomies")
          expect(page).to have_selector(:link_or_button, "Change status")
          expect(page).to have_selector(:link_or_button, "Change dates")
        end
      end

      context "when change taxonomies is selected from actions dropdown" do
        let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
        let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
        let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
        let(:taxonomy_filter_ids) { [taxonomy_filter.id] }

        before do
          click_on "Actions"
          click_on "Change taxonomies"
        end

        it "changes the taxonomies" do
          expect(result.taxonomies).to be_empty
          expect(page).to have_css("#taxonomies_for_filter_#{taxonomy_filter.id}", count: 1)
          expect(page).to have_selector(:link_or_button, "Change taxonomies")
          select decidim_sanitize_translated(taxonomy.name), from: "taxonomies_for_filter_#{taxonomy_filter.id}"
          click_on "Change taxonomies"
          expect(page).to have_admin_callout "Successfully updated taxonomies #{translated(taxonomy.name)} for results"
          expect(result.reload.taxonomies.first).to eq(taxonomy)
        end
      end

      context "when change status is selected from actions dropdown" do
        before do
          click_on "Actions"
          click_on "Change status"
        end

        it "changes the status" do
          select translated(status.name), from: "result_bulk_actions[decidim_accountability_status_id]"
          click_on "Change status"
          expect(page).to have_admin_callout "Results status successfully updated"
          expect(result.reload.status).to eq(status)
          expect(other_result.reload.status).to eq(status)
        end
      end

      context "when change dates is selected from actions dropdown" do
        before do
          click_on "Actions"
          click_on "Change dates"
        end

        it "changes the dates" do
          fill_in "result_bulk_actions_start_date_date", with: "01/01/2025"
          fill_in "result_bulk_actions_end_date_date", with: "02/01/2025"
          click_on "Change date"
          expect(page).to have_admin_callout "Results dates successfully updated"
          expect(result.reload.start_date).to eq(Date.parse("2025-01-01"))
          expect(result.reload.end_date).to eq(Date.parse("2025-01-02"))
        end
      end
    end
  end
end
