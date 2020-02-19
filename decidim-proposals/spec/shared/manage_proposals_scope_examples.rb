# frozen_string_literal: true

shared_examples "when managing proposals scope as an admin" do
  let(:parent_scope) { create :scope, participatory_space: participatory_process }
  let(:scope) { create :scope, participatory_space: participatory_process, parent_id: parent_scope.id }
  let!(:my_scope) { create :scope, participatory_space: participatory_process, parent_id: parent_scope.id }
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
        expect(page).to have_css("span#js-selected-proposals-count", count: 1)
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
          expect(page).to have_selector(:link_or_button, "Change scope")
        end
      end

      context "when change scope is selected from actions dropdown" do
        before do
          click_button "Actions"
          click_button "Change scope"
        end

        it "shows the scope select" do
          expect(page).to have_css("select#scope_id", count: 1)
        end

        it "shows an update button" do
          expect(page).to have_css("button#js-submit-edit-scope", count: 1)
        end
      end

      context "when submiting form" do
        before do
          click_button "Actions"
          click_button "Change scope"
          within "#js-form-recategorize-proposals" do
            select translated(scope.name), from: :scope_id
            page.find("button#js-submit-edit-scope").click
          end
        end

        it "changes to selected scope" do
          expect(page).to have_selector(".success")
        end
      end
    end
  end
end
