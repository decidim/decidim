# frozen_string_literal: true

shared_examples "merge proposals" do
  let!(:proposals) { create_list(:proposal, 3, :official, component: current_component) }
  let(:target_component_minimal) { create(:proposal_component, participatory_space: current_component.participatory_space) }
  let!(:target_component) { target_component_minimal }
  include Decidim::ComponentPathHelper

  before do
    Decidim::Proposals::Proposal.where.not(id: proposals.map(&:id)).destroy_all
  end

  context "when selecting proposals" do
    before do
      visit current_path
      page.find_by_id("proposals_bulk", class: "js-check-all").set(true)
    end

    context "when click the bulk action button" do
      it "shows the change action option" do
        click_on "Actions"

        expect(page).to have_selector(:link_or_button, "Merge into a new one")
      end

      context "when only one proposal is checked" do
        before do
          page.find_by_id("proposals_bulk", class: "js-check-all").set(false)
          page.first(".js-proposal-list-check").set(true)
        end

        it "does not show the merge action option" do
          click_on "Actions"

          expect(page).to have_no_selector(:link_or_button, "Merge into a new one")
        end
      end
    end

    context "when merge into a new one is selected from the actions dropdown" do
      context "when Allow attachments and Maps enabled are disable" do
        context "when submitting the form" do
          before do
            click_on "Actions"
            click_on "Merge into a new one"
            within "#form-merge-proposals" do
              expect(page).to have_css("#target_component_id_", count: 1)
              select translated(target_component.name), from: :target_component_id_
              fill_in_i18n(
                :proposals_merge_title,
                "#proposals_merge-title-tabs",
                en: "My result merge proposal",
                es: "Mi resultado de fusionar las propuestas",
                ca: "El meu result merge proposal"
              )
              fill_in_i18n_editor(
                :proposals_merge_body,
                "#proposals_merge-body-tabs",
                en: "A longer description",
                es: "Descripción más larga",
                ca: "Descripció més llarga"
              )
            end
            expect(page).to have_button(id: "js-submit-merge-proposals", count: 1)
            click_on(id: "js-submit-merge-proposals")
          end

          it "creates a new proposal" do
            expect(page).to have_content("Successfully merged the proposals into a new one")
            expect(page).to have_css(".table-list tbody tr", count: 1)
            expect(page).to have_current_path(manage_component_path(target_component))
          end

          context "when merging to the same component" do
            let!(:target_component) { current_component }
            let!(:proposal_ids) { proposals.map(&:id) }

            context "when the proposals cannot be merged" do
              let!(:proposals) { create_list(:proposal, 3, :with_endorsements, :with_votes, component: current_component) }

              it "does not create a new proposal and displays a validation fail message" do
                expect(page).to have_css(".table-list tbody tr", count: 3)
                expect(page).to have_content("There was a problem merging the selected proposals")
                expect(page).to have_content("Are not official")
                expect(page).to have_content("Have received votes or endorsements")
              end
            end

            it "creates a new proposal and withdraw the other ones" do
              expect(page).to have_content("Successfully merged the proposals into a new one")
              expect(page).to have_css(".table-list tbody tr", count: 4)
              expect(page).to have_current_path(manage_component_path(current_component))

              proposal_ids.each do |id|
                expect(page).to have_xpath("//tr[@data-id='#{id}']")
              end
            end
          end
        end
      end

      context "when Allow attachments and Maps enabled are enable" do
        before do
          current_component.update!(settings: { geocoding_enabled: true, attachments_allowed: true })
          click_on "Actions"
          click_on "Merge into a new one"
        end

        context "when submitting the form" do
          before do
            within "#form-merge-proposals" do
              first(:option, translated(target_component.name)).select_option
              fill_in_i18n(
                :proposals_merge_title,
                "#proposals_merge-title-tabs",
                en: "My result merge proposal",
                es: "Mi resultado de fusionar las propuestas",
                ca: "El meu result merge proposal"
              )
              fill_in_i18n_editor(
                :proposals_merge_body,
                "#proposals_merge-body-tabs",
                en: "A longer description",
                es: "Descripción más larga",
                ca: "Descripció més llarga"
              )
            end
          end

          it "creates a new proposal" do
            expect(page).to have_content("Address")
            expect(page).to have_content("Add images")
            expect(page).to have_content("Attachment or image name")
            expect(page).to have_button(id: "js-submit-merge-proposals", count: 1)
            click_on(id: "js-submit-merge-proposals")
            expect(page).to have_content("Successfully merged the proposals into a new one")
            expect(page).to have_css(".table-list tbody tr", count: 1)
            expect(page).to have_current_path(manage_component_path(target_component))
          end
        end
      end
    end
  end
end
