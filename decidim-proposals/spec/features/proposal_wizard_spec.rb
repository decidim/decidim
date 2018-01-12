# frozen_string_literal: true

require "spec_helper"

describe "Proposal", type: :feature do
  include_context "with a feature"
  let(:manifest_name) { "proposals" }

  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization: organization, scope: scope) }

  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  let(:proposal_title) { "Oriol for president" }
  let(:proposal_body) { "He will solve everything" }

  before do
    Geocoder::Lookup::Test.add_stub(
      address,
      [{ "latitude" => latitude, "longitude" => longitude }]
    )
  end

  matcher :have_author do |name|
    match { |node| node.has_selector?(".author-data", text: name) }
    match_when_negated { |node| node.has_no_selector?(".author-data", text: name) }
  end

  context "when creating a new proposal" do
    let(:scope_picker) { scopes_picker_find(:proposal_scope_id) }

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "with creation enabled" do
        let!(:feature) do
          create(:proposal_feature,
                 :with_creation_enabled,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        context "when access to proposal wizard" do
          before do
            visit_feature
          end

          it "Proposals page contains a create proposal button" do
            expect(page).to have_content("New proposal")
          end
        end

        context "when the user isn't authorized" do
          before do
            permissions = {
              create: {
                authorization_handler_name: "dummy_authorization_handler"
              }
            }

            feature.update_attributes!(permissions: permissions)
          end

          it "shows a modal dialog" do
            visit_feature
            click_link "New proposal"
            expect(page).to have_content("Authorization required")
          end
        end

        context "create a proposal" do
          before do
            visit_feature

            click_link "New proposal"
          end

          context "step_1: Start" do
            it "show current step_1 highlighted" do
              within "#proposal-stepper" do
                expect(page).to have_css(".phase-item--past", count: 1)
                expect(page).to have_css(".phase-item--past.step_1")
              end
            end

            it "fill in title and body" do
              within ".new_proposal" do
                fill_in :proposal_title, with: proposal_title
                fill_in :proposal_body, with: proposal_body
                find("*[type=submit]").click
              end
            end
          end

          context "step_2: Compare" do
            before do
              visit_feature
              visit current_path + "/proposal_wizard/step_1"
              fill_in :proposal_title, with: proposal_title
              fill_in :proposal_body, with: proposal_body
              click_button "Search for similar proposals"
            end

            it "show previous and current step_2 highlighted" do
              within "#proposal-stepper" do
                expect(page).to have_css("#proposal-stepper .phase-item--past", count: 2)
                expect(page).to have_css("#proposal-stepper .phase-item--past.step_2")
              end
            end

            context "with similar results" do
              before do
                create(:proposal, :published, title: "Agusti for president", body: "He will solve everything", feature: feature)
                create(:proposal, :published, title: "Homer for president", body: "He will not solve everything", feature: feature)
                visit_feature
                visit current_path + "/proposal_wizard/step_1"
                fill_in :proposal_title, with: proposal_title
                fill_in :proposal_body, with: proposal_body
                click_button "Search for similar proposals"
              end

              it "shows similar proposals" do
                expect(page).to have_css(".card--proposal", text: "Agusti for president")
                expect(page).to have_css(".card--proposal", count: 2)
              end

              it "show continue and exit wizard buttons" do
                within ".new_proposal" do
                  expect(page).to have_content("There are proposals similar to mine, I want to cancel the creation process")
                  expect(page).to have_content("None of the below matches mine, continue")
                end
              end
            end

            context "without similar results" do
              it "similar proposals are not shown" do
                expect(page).to have_css(".card--proposal", count: 0)
                expect(page).to have_content("No similar proposals were found")
              end

              it "show continue wizard buttons" do
                within ".new_proposal" do
                  expect(page).to have_content("Continue to next step")
                end
              end
            end
          end

          context "step_3: Complete" do
            let(:user_group) { create(:user_group, :verified) }
            before do
              create(:user_group_membership, user: user, user_group: user_group)
              visit_feature
              visit current_path + "/proposal_wizard/step_1"
              fill_in :proposal_title, with: proposal_title
              fill_in :proposal_body, with: proposal_body
              click_button "Search for similar proposals"
              click_button "Continue to next step"
            end

            it "show previous and current step_3 highlighted" do
              within "#proposal-stepper" do
                expect(page).to have_css("#proposal-stepper .phase-item--past", count: 3)
                expect(page).to have_css("#proposal-stepper .phase-item--past.step_3.step_3")
              end
            end

            context "when process is not related to any scope" do
              it "can be related to a scope" do
                within "form.new_proposal" do
                  expect(page).to have_content(/Scope/i)
                end
              end
            end

            context "when process is related to a leaf scope" do
              let(:participatory_process) { scoped_participatory_process }

              it "cannot be related to a scope" do
                within "form.new_proposal" do
                  expect(page).to have_no_content("Scope")
                end
              end
            end

            context "has all proposal fields" do
              it "has basic fields" do
                expect(page).to have_content("Category")
                expect(page).to have_content("Scope")
                expect(page).to have_content("Preview the proposal")
              end

              context "when the user has verified organizations" do
                it "has user group select" do
                  expect(page).to have_content("Create proposal as")
                  expect(page).to have_css("#proposal_user_group_id")
                end
              end

              context "when geocoding is enabled", :serves_map do
                let!(:feature) do
                  create(:proposal_feature,
                         :with_creation_enabled,
                         :with_geocoding_enabled,
                         manifest: manifest,
                         participatory_space: participatory_process)
                end
                it "has address field" do
                  expect(page).to have_content("address")
                  expect(page).to have_css("#proposal_has_address")
                end
              end

              context "when attachments are allowed", processing_uploads_for: Decidim::AttachmentUploader do
                let!(:feature) do
                  create(:proposal_feature,
                         :with_creation_enabled,
                         :with_attachments_allowed,
                         manifest: manifest,
                         participatory_space: participatory_process)
                end

                it "show attachments fields" do
                  expect(page).to have_content("Add an attachment")
                  expect(page).to have_css("#proposal_attachment_title")
                  expect(page).to have_css("#proposal_attachment_file")
                end
              end
            end
          end # context "step_3: Complete"

          context "step_4: Publish" do
            before do
              visit_feature
              visit current_path + "/proposal_wizard/step_1"
              fill_in :proposal_title, with: proposal_title
              fill_in :proposal_body, with: proposal_body
              click_button "Search for similar proposals"
              click_button "Continue to next step"
              select translated(category.name), from: :proposal_category_id
              scope_pick scope_picker, scope
              click_button "Preview the proposal"
            end

            it "show previous and current step_4 highlighted" do
              within "#proposal-stepper" do
                expect(page).to have_css("#proposal-stepper .phase-item--past", count: 4)
                expect(page).to have_css("#proposal-stepper .phase-item--past.step_4.step_4")
              end
            end

            it "shows the proposal preview" do
              expect(page).to have_content("Oriol for president")
              expect(page).to have_content("He will solve everything")
              expect(page).to have_css(".author__name")
            end

            it "shows the publish proposal button" do
              expect(page).to have_css(".button", text: "correct")
            end

            it "shows the correct proposal button" do
              expect(page).to have_css(".button", text: "Publish the proposal")
            end
          end

          context "published proposal" do
            before do
              visit_feature
              visit current_path + "/proposal_wizard/step_1"
              fill_in :proposal_title, with: proposal_title
              fill_in :proposal_body, with: proposal_body
              click_button "Search for similar proposals"
              click_button "Continue to next step"
              select translated(category.name), from: :proposal_category_id
              scope_pick scope_picker, scope
              click_button "Preview the proposal"
              click_link "Publish the proposal"
            end

            it "publishes the new proposal" do
              expect(page).to have_content("successfully")
              expect(page).to have_content("Oriol for president")
              expect(page).to have_content("He will solve everything")
              expect(page).to have_content(translated(category.name))
              expect(page).to have_content(translated(scope.name))
            end
          end
        end
      end
    end
  end
end
