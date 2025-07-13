# frozen_string_literal: true

shared_examples "when managing proposals taxonomies as an admin" do
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let(:taxonomy_filter_ids) { [taxonomy_filter.id] }
  let!(:component) { create(:component, manifest:, participatory_space:, settings: { taxonomy_filters: taxonomy_filter_ids }) }

  context "when in the Proposals list page" do
    it "shows a checkbox to select each proposal" do
      expect(page).to have_css(".table-list tbody .js-proposal-list-check", count: 4)
    end

    it "shows a checkbox to (des)select all proposal" do
      expect(page).to have_css(".table-list thead .js-check-all", count: 1)
    end

    context "when selecting proposals" do
      before do
        page.find_by_id("proposals_bulk", class: "js-check-all").set(true)
      end

      it "shows the number of selected proposals" do
        expect(page).to have_css("span#js-selected-proposals-count", count: 1)
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

        it "shows the change action option" do
          expect(page).to have_selector(:link_or_button, "Change taxonomies")
        end
      end

      context "when change taxonomies is selected from actions dropdown" do
        before do
          click_on "Actions"
          click_on "Change taxonomies"
        end

        it "changes the taxonomies" do
          expect(proposal.taxonomies).to be_empty
          expect(page).to have_css("#taxonomies_for_filter_#{taxonomy_filter.id}", count: 1)
          expect(page).to have_button(id: "js-submit-taxonomy-change-proposals", count: 1)
          select decidim_sanitize_translated(taxonomy.name), from: "taxonomies_for_filter_#{taxonomy_filter.id}"
          click_on "Change taxonomies"
          expect(page).to have_admin_callout "Proposals successfully updated to the #{translated(taxonomy.name)} taxonomies"
          expect(proposal.reload.taxonomies.first).to eq(taxonomy)
        end
      end
    end
  end
end
