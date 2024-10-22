# frozen_string_literal: true

require "spec_helper"

describe "Collaborative drafts" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:category) { create(:category, participatory_space: participatory_process) }
  let!(:scope) { create(:scope, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization:, scope:) }

  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  let(:collaborative_draft_title) { "More sidewalks and less roads" }
  let(:collaborative_draft_body) { "Cities need more people, not more cars" }

  before do
    stub_geocoding(address, [latitude, longitude])
  end

  matcher :have_author do |name|
    match { |node| node.has_selector?("[data-author]", text: name) }
    match_when_negated { |node| node.has_no_selector?("[data-author]", text: name) }
  end

  context "when creating a new collaborative_draft" do
    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "with creation enabled" do
        let!(:component) do
          create(:proposal_component,
                 :with_creation_enabled,
                 manifest:,
                 participatory_space: participatory_process,
                 settings: {
                   collaborative_drafts_enabled: true,
                   scopes_enabled: true,
                   scope_id: participatory_process.scope&.id
                 })
        end

        context "when process is not related to any scope" do
          it "can be related to a scope" do
            visit new_collaborative_draft_path

            within "form.new_collaborative_draft" do
              expect(page).to have_content(/Scope/i)
            end
          end
        end

        context "when process is related to a leaf scope" do
          let(:participatory_process) { scoped_participatory_process }

          it "cannot be related to a scope" do
            visit new_collaborative_draft_path

            within "form.new_collaborative_draft" do
              expect(page).to have_no_content("Scope")
            end
          end
        end

        it "creates a new collaborative draft", :slow do
          visit new_collaborative_draft_path
          visit new_collaborative_draft_path

          within ".new_collaborative_draft" do
            fill_in :collaborative_draft_title, with: "More sidewalks and less roads"
            fill_in :collaborative_draft_body, with: "Cities need more people, not more cars"
            select translated(category.name), from: :collaborative_draft_category_id
            select translated(scope.name), from: :collaborative_draft_scope_id

            find("*[type=submit]").click
          end

          expect(page).to have_content("successfully")
          expect(page).to have_content("More sidewalks and less roads")
          expect(page).to have_content("Cities need more people, not more cars")
          expect(page).to have_content(translated(category.name))
          expect(page).to have_content(translated(scope.name))
          expect(page).to have_author(user.name)
        end

        context "when there are errors on the form", :slow do
          before do
            visit new_collaborative_draft_path

            within ".new_collaborative_draft" do
              fill_in :collaborative_draft_title, with: "More sidewalks and less roads"
              fill_in :collaborative_draft_body, with: "Cities"

              find("*[type=submit]").click
            end
          end

          it "shows the form with the error message" do
            expect(page).to have_content("There was a problem creating this collaborative draft.")
            expect(page).to have_field(:collaborative_draft_title, with: "More sidewalks and less roads")
            expect(page).to have_field(:collaborative_draft_body, with: "Cities")
          end

          it "allows returning to the index" do
            click_on "Back to collaborative drafts"

            expect(page).to have_content("There are no collaborative drafts yet")
          end
        end

        context "when geocoding is enabled", :serves_geocoding_autocomplete do
          let!(:component) do
            create(:proposal_component,
                   :with_creation_enabled,
                   manifest:,
                   participatory_space: participatory_process)
          end

          before do
            component.update!(settings: {
                                geocoding_enabled: true,
                                collaborative_drafts_enabled: true,
                                scopes_enabled: true,
                                scope_id: participatory_process.scope&.id
                              })
          end

          it "creates a new collaborative draft", :slow do
            visit new_collaborative_draft_path

            within ".new_collaborative_draft" do
              fill_in :collaborative_draft_title, with: "More sidewalks and less roads"
              fill_in :collaborative_draft_body, with: "Cities need more people, not more cars"
              fill_in_geocoding :collaborative_draft_address, with: address
              select translated(category.name), from: :collaborative_draft_category_id
              select translated(scope.name), from: :collaborative_draft_scope_id

              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")
            expect(page).to have_content("More sidewalks and less roads")
            expect(page).to have_content("Cities need more people, not more cars")
            expect(page).to have_content(address)
            expect(page).to have_content(translated(category.name))
            expect(page).to have_content(translated(scope.name))
            expect(page).to have_author(user.name)
          end

          it_behaves_like(
            "a record with front-end geocoding address field",
            Decidim::Proposals::CollaborativeDraft,
            within_selector: ".new_collaborative_draft",
            address_field: :collaborative_draft_address
          ) do
            let(:geocoded_address_value) { address }
            let(:geocoded_address_coordinates) { [latitude, longitude] }

            before do
              # Prepare the view for submission (other than the address field)
              visit new_collaborative_draft_path

              within ".new_collaborative_draft" do
                fill_in :collaborative_draft_title, with: "More sidewalks and less roads"
                fill_in :collaborative_draft_body, with: "Cities need more people, not more cars"
              end
            end
          end
        end

        context "when component has extra hashtags defined" do
          let(:component) do
            create(:proposal_component,
                   :with_collaborative_drafts_enabled,
                   :with_extra_hashtags,
                   suggested_hashtags: component_suggested_hashtags,
                   automatic_hashtags: component_automatic_hashtags,
                   manifest:,
                   participatory_space: participatory_process)
          end

          let(:component_automatic_hashtags) { "AutoHashtag1 AutoHashtag2" }
          let(:component_suggested_hashtags) { "SuggestedHashtag1 SuggestedHashtag2" }

          before do
            component.update!(settings: {
                                collaborative_drafts_enabled: true,
                                scopes_enabled: true,
                                scope_id: participatory_process.scope&.id
                              })
          end

          it "offers and save extra hashtags", :slow do
            visit new_collaborative_draft_path

            within ".new_collaborative_draft" do
              fill_in :collaborative_draft_title, with: "More sidewalks and less roads"
              fill_in :collaborative_draft_body, with: "Cities need more people, not more cars"

              check :collaborative_draft_suggested_hashtags_suggestedhashtag1

              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")
            expect(page).to have_content("#AutoHashtag1")
            expect(page).to have_content("#AutoHashtag2")
            expect(page).to have_content("#SuggestedHashtag1")
            expect(page).to have_no_content("#SuggestedHashtag2")
          end
        end

        context "when the user has verified organizations" do
          let(:user_group) { create(:user_group, :verified, organization:) }

          before do
            create(:user_group_membership, user:, user_group:)
          end

          it "creates a new collaborative draft as a user group", :slow do
            visit new_collaborative_draft_path

            within ".new_collaborative_draft" do
              fill_in :collaborative_draft_title, with: "More sidewalks and less roads"
              fill_in :collaborative_draft_body, with: "Cities need more people, not more cars"
              select translated(category.name), from: :collaborative_draft_category_id
              select translated(scope.name), from: :collaborative_draft_scope_id
              select user_group.name, from: :collaborative_draft_user_group_id

              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")
            expect(page).to have_content("More sidewalks and less roads")
            expect(page).to have_content("Cities need more people, not more cars")
            expect(page).to have_content(translated(category.name))
            expect(page).to have_content(translated(scope.name))
            expect(page).to have_author(user_group.name)
          end

          context "when geocoding is enabled", :serves_geocoding_autocomplete do
            let!(:component) do
              create(:proposal_component,
                     :with_creation_enabled,
                     manifest:,
                     participatory_space: participatory_process,
                     settings: {
                       geocoding_enabled: true,
                       collaborative_drafts_enabled: true,
                       scopes_enabled: true,
                       scope_id: participatory_process.scope&.id
                     })
            end

            it "creates a new collaborative draft as a user group", :slow do
              visit new_collaborative_draft_path

              within ".new_collaborative_draft" do
                fill_in :collaborative_draft_title, with: "More sidewalks and less roads"
                fill_in :collaborative_draft_body, with: "Cities need more people, not more cars"
                fill_in :collaborative_draft_address, with: address
                select translated(category.name), from: :collaborative_draft_category_id
                select translated(scope.name), from: :collaborative_draft_scope_id
                select user_group.name, from: :collaborative_draft_user_group_id

                find("*[type=submit]").click
              end

              expect(page).to have_content("successfully")
              expect(page).to have_content("More sidewalks and less roads")
              expect(page).to have_content("Cities need more people, not more cars")
              expect(page).to have_content(address)
              expect(page).to have_content(translated(category.name))
              expect(page).to have_content(translated(scope.name))
              expect(page).to have_author(user_group.name)
            end
          end
        end

        context "when the user is not authorized" do
          context "and there is only an authorization required" do
            before do
              permissions = {
                create: {
                  authorization_handlers: {
                    "dummy_authorization_handler" => { "options" => {} }
                  }
                }
              }

              component.update!(permissions:)
            end

            it "redirects to the authorization form" do
              visit_component
              click_on "Access collaborative drafts"
              click_on "New collaborative draft"
              expect(page).to have_content("We need to verify your identity")
              expect(page).to have_content("Verify with Example authorization")
            end
          end

          context "and there are more than one authorization required" do
            before do
              permissions = {
                create: {
                  authorization_handlers: {
                    "dummy_authorization_handler" => { "options" => {} },
                    "another_dummy_authorization_handler" => { "options" => {} }
                  }
                }
              }

              component.update!(permissions:)
            end

            it "redirects to pending onboarding authorizations page" do
              visit_component
              click_on "Access collaborative drafts"
              click_on "New collaborative draft"
              expect(page).to have_content("You are almost ready to create a proposal")
              expect(page).to have_css("a[data-verification]", count: 2)
            end
          end
        end

        context "when attachments are allowed" do
          let!(:component) do
            create(:proposal_component,
                   :with_creation_enabled,
                   :with_attachments_allowed_and_collaborative_drafts_enabled,
                   manifest:,
                   participatory_space: participatory_process)
          end

          it "creates a new collaborative draft with attachments" do
            visit new_collaborative_draft_path

            within ".new_collaborative_draft" do
              fill_in :collaborative_draft_title, with: "Collaborative draft with attachments"
              fill_in :collaborative_draft_body, with: "This is my collaborative draft and I want to upload attachments."
            end

            dynamically_attach_file(:collaborative_draft_documents, Decidim::Dev.asset("city.jpeg"))

            within ".new_collaborative_draft" do
              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")

            within "#panel-images" do
              expect(page).to have_css("img[src*=\"city.jpeg\"]", count: 1)
            end
          end
        end
      end

      context "when creation is not enabled" do
        let!(:component) do
          create(:proposal_component,
                 :with_collaborative_drafts_enabled,
                 manifest:,
                 participatory_space: participatory_process)
        end

        it "does not show the creation button" do
          visit_component
          click_on "Access collaborative drafts"
          expect(page).to have_no_link("New collaborative draft")
        end
      end
    end
  end
end

def new_collaborative_draft_path
  visit_component
  "#{current_proposal_path}/collaborative_drafts/new"
end

def current_proposal_path
  current_path.sub("/proposals", "")
end
