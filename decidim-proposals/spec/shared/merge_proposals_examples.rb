# frozen_string_literal: true

shared_examples "merge proposals" do
  let!(:proposals) { create_list :proposal, 3, :official, component: current_component }
  let!(:target_component) { create :proposal_component, participatory_space: current_component.participatory_space }
  include Decidim::ComponentPathHelper

  before do
    Decidim::Proposals::Proposal.where.not(id: proposals.map(&:id)).destroy_all
  end

  context "when selecting proposals" do
    before do
      visit current_path
      page.find("#proposals_bulk.js-check-all").set(true)
    end

    context "when click the bulk action button" do
      it "shows the change action option" do
        click_button "Actions"

        expect(page).to have_selector(:link_or_button, "Merge into a new one")
      end

      context "when only one proposal is checked" do
        before do
          page.find("#proposals_bulk.js-check-all").set(false)
          page.first(".js-proposal-list-check").set(true)
        end

        it "does not show the merge action option" do
          click_button "Actions"

          expect(page).to have_no_selector(:link_or_button, "Merge into a new one")
        end
      end
    end

    context "when merge into a new one is selected from the actions dropdown" do
      before do
        click_button "Actions"
        click_button "Merge into a new one"
      end

      it "shows the component select" do
        expect(page).to have_css("#js-form-merge-proposals select", count: 1)
      end

      it "shows an update button" do
        expect(page).to have_css("button#js-submit-merge-proposals", count: 1)
      end

      context "when submiting the form" do
        before do
          within "#js-form-merge-proposals" do
            select translated(target_component.name), from: :target_component_id_
            page.find("button#js-submit-merge-proposals").click
          end
        end

        it "creates a new proposal" do
          expect(page).to have_content("Successfully merged the proposals into a new one")
          expect(page).to have_css(".table-list tbody tr", count: 1)
          expect(page).to have_current_path(manage_component_path(target_component))
        end

        context "when merging to the same component" do
          let!(:target_component) { current_component }
          let!(:proposal_ids) { proposals.map(&:id) }

          context "when the proposals can't be merged" do
            let!(:proposals) { create_list :proposal, 3, :with_endorsements, :with_votes, component: current_component }

            it "doesn't create a new proposal and displays a validation fail message" do
              expect(page).to have_css(".table-list tbody tr", count: 3)
              expect(page).to have_content("There has been a problem merging the selected proposals")
              expect(page).to have_content("Are not official")
              expect(page).to have_content("Have received support or endorsements")
            end
          end

          it "creates a new proposal and deletes the other ones" do
            expect(page).to have_content("Successfully merged the proposals into a new one")
            expect(page).to have_css(".table-list tbody tr", count: 1)
            expect(page).to have_current_path(manage_component_path(current_component))

            proposal_ids.each do |id|
              expect(page).not_to have_xpath("//tr[@data-id='#{id}']")
            end
          end
        end
      end
    end
  end
end
