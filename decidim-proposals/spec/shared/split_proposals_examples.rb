# frozen_string_literal: true

shared_examples "split proposals" do
  let!(:proposals) { create_list :proposal, 3, component: current_component }
  let!(:target_component) { create :proposal_component, participatory_space: current_component.participatory_space }
  include Decidim::ComponentPathHelper

  context "when selecting proposals" do
    before do
      visit current_path
      page.find("#proposals_bulk.js-check-all").set(true)
    end

    context "when click the bulk action button" do
      before do
        click_button "Actions"
      end

      it "shows the change action option" do
        expect(page).to have_selector(:link_or_button, "Split proposals")
      end
    end

    context "when split into a new one is selected from the actions dropdown" do
      before do
        page.find("#proposals_bulk.js-check-all").set(false)
        page.first(".js-proposal-list-check").set(true)

        click_button "Actions"
        click_button "Split proposals"
      end

      it "shows the component select" do
        expect(page).to have_css("#js-form-split-proposals select", count: 1)
      end

      it "shows an update button" do
        expect(page).to have_css("button#js-submit-split-proposals", count: 1)
      end

      context "when submiting the form" do
        before do
          within "#js-form-split-proposals" do
            select translated(target_component.name), from: :target_component_id_
            page.find("button#js-submit-split-proposals").click
          end
        end

        it "creates a new proposal" do
          expect(page).to have_content("Successfully splitted the proposals into new ones")
          expect(page).to have_css(".table-list tbody tr", count: 2)
        end
      end
    end
  end
end
