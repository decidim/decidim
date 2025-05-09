# frozen_string_literal: true

shared_examples "merge proposals" do
  let!(:proposals) { create_list(:proposal, 3, :official, component: current_component) }
  let(:target_component_minimal) { create(:proposal_component, participatory_space: current_component.participatory_space) }
  let!(:target_component) { target_component_minimal }
  let!(:meeting_component) { create(:meeting_component, participatory_space: participatory_process) }
  let!(:meetings) { create_list(:meeting, 3, :published, component: meeting_component) }
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
              expect(page).to have_content("This proposal comes from a meeting")
              check "proposals_merge_created_in_meeting"
              expect(page).to have_content("Select a meeting")
              select translated(meetings.first.title), from: :proposals_merge_meeting_id
            end
            expect(page).to have_button(id: "js-submit-merge-proposals", count: 1)
            click_on(id: "js-submit-merge-proposals")
          end

          it "creates a new proposal" do
            expect(page).to have_content("Successfully merged the proposals into a new one")
            expect(page).to have_css(".table-list tbody tr", count: 1)
            expect(page).to have_current_path(manage_component_path(target_component))
          end

          context "when merging to another component" do
            before do
              click_on "My result merge proposal"
              wait = Selenium::WebDriver::Wait.new(timeout: 10)
              wait.until { page.driver.browser.switch_to.alert }
              alert = page.driver.browser.switch_to.alert
              alert.accept
              new_proposal_url = find("a", text: "See proposal")[:href]
              visit new_proposal_url
            end

            context "when result proposal comes from a meeting" do
              it "shows meeting as the first author" do
                expect(page).to have_css(".main-bar__logo")
                expect(page).to have_content("Official proposal")
                expect(page).to have_content("It was discussed in this meeting")
              end

              it "shows the result proposal with history panel" do
                expect(page).to have_content("History")
                expect(page).to have_css(".resource_history__item_icon")
                expect(page).to have_content("This proposal was created")
              end
            end
          end

          context "when merging to the same component" do
            let!(:target_component) { current_component }
            let!(:proposal_ids) { proposals.map(&:id) }

            context "when the proposals cannot be merged" do
              let!(:proposals) { create_list(:proposal, 3, :with_endorsements, :with_votes, component: current_component) }

              it "does not create a new proposal and displays a validation fail message" do
                expect(page).to have_css(".table-list tbody tr", count: 3)
                expect(page).to have_content("Have received votes or likes")
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

            it "shows withdrawn status in the original proposals" do
              expect(page).to have_css(".table-list tbody tr", count: 4)
              expect(page).to have_content("Withdrawn", count: 3)
            end

            it "shows the recorded action in the admin log" do
              click_on "Admin activity log"
              expect(page).to have_content("created the proposal My result merge proposal from the merging of")
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
            expect(page).to have_content("Add attachments")
            expect(page).to have_content("Add a document or an image")
            expect(page).to have_button(id: "js-submit-merge-proposals", count: 1)
            click_on(id: "js-submit-merge-proposals")
            expect(page).to have_content("Successfully merged the proposals into a new one")
            expect(page).to have_css(".table-list tbody tr", count: 1)
            expect(page).to have_current_path(manage_component_path(target_component))
          end

          context "when result proposal does not comes from a meeting" do
            before do
              click_on "Create"
              click_on "My result merge proposal"
              new_proposal_url = find("a", text: "See proposal")[:href]
              visit new_proposal_url
            end

            it "shows official proposal as the first author" do
              expect(page).to have_css(".main-bar__logo")
              expect(page).to have_content("Official proposal")
            end

            it "shows the result proposal with history panel" do
              expect(page).to have_content("History")
              expect(page).to have_css(".resource_history__item_icon")
              expect(page).to have_content("This proposal was created")
            end
          end
        end
      end
    end
  end
end
