# frozen_string_literal: true

shared_examples "when managing proposals category as an admin" do
  let(:parent_category) { create :category, participatory_space: participatory_process }
  let(:category) { create :category, participatory_space: participatory_process, parent_id: parent_category.id }
  let!(:my_category) { create :category, participatory_space: participatory_process, parent_id: parent_category.id }
  let!(:proposal_first) { reportables.first }
  let!(:proposal_last) { reportables.last }

  context "when in the Proposals list page" do
    it "shows a checkbox to select each proposal" do
      expect(page).to have_css(".table-list tbody .js-proposal-list-check", count: 4)
    end

    it "shows a checkbox to (des)select all proposal" do
      expect(page).to have_css(".table-list thead .js-check-all", count: 1)
    end

    context "when selecting proposals" do
      before do
        page.find("#proposals_bulk.js-check-all").set(true)
      end

      it "shows the number of selected proposals" do
        expect(page).to have_css("span#js-bulk-actions-button", count: 1)
      end

      it "shows the bulk actions button" do
        expect(page).to have_css("#js-bulk-actions-button", count: 1)
      end

      context "when click the bulk action button" do
        before do
          click_button "Actions"
        end

        it "shows the bulk actions dropdown" do
          expect(page).to have_css("#js-bulk-actions-dropdown", count: 1)
        end

        it "shows the change action option" do
          expect(page).to have_selector(:link_or_button, "Change category")
        end
      end

      context "when change category is selected from actions dropdown" do
        before do
          click_button "Actions"
          click_button "Change category"
        end

        it "shows the category select" do
          expect(page).to have_css("select#category_id", count: 1)
        end

        it "shows an update button" do
          expect(page).to have_css("button#js-submit-edit-category", count: 1)
        end
      end

      context "when submiting form" do
        before do
          click_button "Actions"
          click_button "Change category"
          within "#js-form-recategorize-proposals" do
            select translated(category.name), from: :category_id
            page.find("button#js-submit-edit-category").click
          end
        end

        it "changes to selected category" do
          expect(page).to have_selector(".success")
        end
      end
    end
  end
end
