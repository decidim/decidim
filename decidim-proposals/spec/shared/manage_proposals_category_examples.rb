# frozen_string_literal: true

shared_examples "when managing proposals category as an admin" do
  let(:parent_category) { create :category, participatory_space: participatory_process }
  let(:category) { create :category, participatory_space: participatory_process, parent_id: parent_category.id }
  let!(:my_category) { create :category, participatory_space: participatory_process, parent_id: parent_category.id }
  let!(:proposal_first) { reportables.first }
  let!(:proposal_last) { reportables.last }

  context "Proposals list page" do
    it "shows a checkbox to select each proposal" do
      expect(page).to have_css("#js-form-recategorize-proposals tbody .js-check-all-proposal", count: 4)
    end

    it "shows a checkbox to (des)select all proposal" do
      expect(page).to have_css("#js-form-recategorize-proposals thead .js-check-all", count: 1)
    end

    context "when selecting proposals" do
      before do
        page.find("#proposals_recategorize.js-check-all").set(true)
      end

      it "shows the number of selected proposals" do
        expect(page).to have_css("span#js-recategorize-proposals-count", count: 1)
      end

      it "shows a category select" do
        expect(page).to have_css("select#category_id", count: 1)
      end

      it "shows a submit button" do
        expect(page).to have_css("button#js-submit-edit-category", count: 1)
      end

      context "when submiting form" do
        before do
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
