# frozen_string_literal: true

shared_examples "when managing proposals category as an admin" do
  let(:parent_category) { create(:category, participatory_space: participatory_process) }
  let(:category) { create(:category, participatory_space: participatory_process, parent_id: parent_category.id) }
  let!(:my_category) { create(:category, participatory_space: participatory_process, parent_id: parent_category.id) }
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
          expect(page).to have_selector(:link_or_button, "Change category")
        end
      end

      context "when change category is selected from actions dropdown" do
        before do
          click_on "Actions"
          click_on "Change category"
        end

        it "shows the category select" do
          expect(page).to have_select(id: "category_id", count: 1)
        end

        it "shows an update button" do
          expect(page).to have_button(id: "js-submit-edit-category", count: 1)
        end
      end

      context "when submitting form" do
        before do
          click_on "Actions"
          click_on "Change category"
          within "#js-form-recategorize-proposals" do
            select translated(category.name), from: :category_id
            click_on(id: "js-submit-edit-category")
          end
        end

        it "changes to selected category" do
          expect(page).to have_css(".success")
        end
      end
    end

    context "when updating multiple proposals consecutively" do
      before do
        find("tr[data-id=\"#{proposal_first.id}\"] input").set(true)
        click_on "Actions"
        click_on "Change category"
        within "#js-form-recategorize-proposals" do
          select translated(category.name), from: :category_id
          click_on(id: "js-submit-edit-category")
        end

        expect(page).to have_css(".success")
      end

      it "updates both correctly" do
        find("tr[data-id=\"#{proposal_last.id}\"] input").set(true)
        click_on "Actions"
        click_on "Change category"
        within "#js-form-recategorize-proposals" do
          select translated(parent_category.name), from: :category_id
          click_on(id: "js-submit-edit-category")
        end

        within "tr[data-id=\"#{proposal_first.id}\"]" do
          expect(page).to have_content(translated(category.name))
        end

        within "tr[data-id=\"#{proposal_last.id}\"]" do
          expect(page).to have_content(translated(parent_category.name))
        end
      end
    end
  end
end
