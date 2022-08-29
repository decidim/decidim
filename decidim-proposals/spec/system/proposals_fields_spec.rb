# frozen_string_literal: true

require "spec_helper"

describe "Proposals", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: }
  let!(:user) { create :user, :confirmed, organization: }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization:, scope:) }

  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  let(:proposal_title) { "More sidewalks and less roads" }
  let(:proposal_body) { "Cities need more people, not more cars" }

  before do
    stub_geocoding(address, [latitude, longitude])
  end

  matcher :have_author do |name|
    match { |node| node.has_selector?(".author-data", text: name) }
    match_when_negated { |node| node.has_no_selector?(".author-data", text: name) }
  end

  context "when creating a new proposal" do
    let(:scope_picker) { select_data_picker(:proposal_scope_id) }

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
                 settings: { scopes_enabled: true, scope_id: participatory_process.scope&.id })
        end

        let(:proposal_draft) { create(:proposal, :draft, component:, users: [user]) }

        context "when process is not related to any scope" do
          it "can be related to a scope" do
            visit complete_proposal_path(component, proposal_draft)

            within "form.edit_proposal" do
              expect(page).to have_content(/Scope/i)
            end
          end
        end

        context "when process is related to a leaf scope" do
          let(:participatory_process) { scoped_participatory_process }

          it "cannot be related to a scope" do
            visit complete_proposal_path(component, proposal_draft)

            within "form.edit_proposal" do
              expect(page).to have_no_content("Scope")
            end
          end
        end

        it "creates a new proposal", :slow do
          visit complete_proposal_path(component, proposal_draft)

          within ".edit_proposal" do
            fill_in :proposal_title, with: "More sidewalks and less roads"
            fill_in :proposal_body, with: "Cities need more people, not more cars"
            select translated(category.name), from: :proposal_category_id
            scope_pick scope_picker, scope

            find("*[type=submit]").click
          end

          expect(page).not_to have_css(".address__info")
          expect(page).not_to have_css(".address__map")

          click_button "Publish"

          expect(page).to have_content("successfully")
          expect(page).to have_content("More sidewalks and less roads")
          expect(page).to have_content("Cities need more people, not more cars")
          expect(page).to have_content(translated(category.name))
          expect(page).to have_content(translated(scope.name))
          expect(page).to have_author(user.name)
        end

        context "when geocoding is enabled", :serves_map, :serves_geocoding_autocomplete do
          let!(:component) do
            create(:proposal_component,
                   :with_creation_enabled,
                   manifest:,
                   participatory_space: participatory_process,
                   settings: {
                     geocoding_enabled: true,
                     scopes_enabled: true,
                     scope_id: participatory_process.scope&.id
                   })
          end

          let(:proposal_draft) { create(:proposal, :draft, users: [user], component:, title: "More sidewalks and less roads", body: "It will not solve everything") }

          it "creates a new proposal", :slow do
            visit complete_proposal_path(component, proposal_draft)

            within ".edit_proposal" do
              check :proposal_has_address
              fill_in :proposal_title, with: "More sidewalks and less roads"
              fill_in :proposal_body, with: "Cities need more people, not more cars"
              fill_in_geocoding :proposal_address, with: address

              expect(page).to have_css("[data-decidim-map]")
              expect(page).to have_content("You can move the point on the map.")

              select translated(category.name), from: :proposal_category_id
              scope_pick scope_picker, scope

              find("*[type=submit]").click
            end

            within ".card__content.address" do
              expect(page).to have_css(".address__info")
              expect(page).to have_css(".address__map")
              expect(page).to have_content(address)
            end

            click_button "Publish"

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
            Decidim::Proposals::Proposal,
            within_selector: ".edit_proposal",
            address_field: :proposal_address
          ) do
            let(:geocoded_record) { proposal_draft }
            let(:geocoded_address_value) { address }
            let(:geocoded_address_coordinates) { [latitude, longitude] }

            before do
              # Prepare the view for submission (other than the address field)
              visit complete_proposal_path(component, proposal_draft)

              check :proposal_has_address
              fill_in :proposal_title, with: "More sidewalks and less roads"
              fill_in :proposal_body, with: "Cities need more people, not more cars"
            end
          end
        end

        context "when component has extra hashtags defined" do
          let(:component) do
            create(:proposal_component,
                   :with_extra_hashtags,
                   suggested_hashtags: component_suggested_hashtags,
                   automatic_hashtags: component_automatic_hashtags,
                   manifest:,
                   participatory_space: participatory_process)
          end

          let(:proposal_draft) { create(:proposal, :draft, users: [user], component:, title: "More sidewalks and less roads", body: "It will not solve everything") }
          let(:component_automatic_hashtags) { "AutoHashtag1 AutoHashtag2" }
          let(:component_suggested_hashtags) { "SuggestedHashtag1 SuggestedHashtag2" }

          it "offers and save extra hashtags", :slow do
            visit complete_proposal_path(component, proposal_draft)

            within ".edit_proposal" do
              check :proposal_suggested_hashtags_suggestedhashtag1

              find("*[type=submit]").click
            end

            click_button "Publish"

            expect(page).to have_content("successfully")
            expect(page).to have_content("#AutoHashtag1")
            expect(page).to have_content("#AutoHashtag2")
            expect(page).to have_content("#SuggestedHashtag1")
            expect(page).not_to have_content("#SuggestedHashtag2")
          end
        end

        context "when the user has verified organizations" do
          let(:user_group) { create(:user_group, :verified, organization:) }
          let(:user_group_proposal_draft) { create(:proposal, :draft, users: [user], component:, title: "More sidewalks and less roads", body: "Cities need more people, not more cars") }

          before do
            create(:user_group_membership, user:, user_group:)
          end

          it "creates a new proposal as a user group", :slow do
            visit complete_proposal_path(component, user_group_proposal_draft)

            within ".edit_proposal" do
              fill_in :proposal_title, with: "More sidewalks and less roads"
              fill_in :proposal_body, with: "Cities need more people, not more cars"
              select translated(category.name), from: :proposal_category_id
              scope_pick scope_picker, scope
              select user_group.name, from: :proposal_user_group_id

              find("*[type=submit]").click
            end

            click_button "Publish"

            expect(page).to have_content("successfully")
            expect(page).to have_content("More sidewalks and less roads")
            expect(page).to have_content("Cities need more people, not more cars")
            expect(page).to have_content(translated(category.name))
            expect(page).to have_content(translated(scope.name))
            expect(page).to have_author(user_group.name)
          end

          context "when geocoding is enabled", :serves_map, :serves_geocoding_autocomplete do
            let!(:component) do
              create(:proposal_component,
                     :with_creation_enabled,
                     manifest:,
                     participatory_space: participatory_process,
                     settings: {
                       geocoding_enabled: true,
                       scopes_enabled: true,
                       scope_id: participatory_process.scope&.id
                     })
            end

            let(:proposal_draft) { create(:proposal, :draft, users: [user], component:, title: "More sidewalks and less roads", body: "It will not solve everything") }

            it "creates a new proposal as a user group", :slow do
              visit complete_proposal_path(component, proposal_draft)

              within ".edit_proposal" do
                fill_in :proposal_title, with: "More sidewalks and less roads"
                fill_in :proposal_body, with: "Cities need more people, not more cars"
                check :proposal_has_address
                fill_in :proposal_address, with: address
                select translated(category.name), from: :proposal_category_id
                scope_pick scope_picker, scope
                select user_group.name, from: :proposal_user_group_id

                find("*[type=submit]").click
              end

              click_button "Publish"

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

        context "when the user isn't authorized" do
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

          it "shows a modal dialog" do
            visit_component
            click_link "New proposal"
            expect(page).to have_content("Authorization required")
          end
        end

        context "when attachments are allowed" do
          let!(:component) do
            create(:proposal_component,
                   :with_creation_enabled,
                   :with_attachments_allowed,
                   manifest:,
                   participatory_space: participatory_process)
          end

          let(:proposal_draft) { create(:proposal, :draft, users: [user], component:, title: "Proposal with attachments", body: "This is my proposal and I want to upload attachments.") }

          it "creates a new proposal with attachments" do
            visit complete_proposal_path(component, proposal_draft)

            within ".edit_proposal" do
              fill_in :proposal_title, with: "Proposal with attachments"
              fill_in :proposal_body, with: "This is my proposal and I want to upload attachments."
            end

            dynamically_attach_file(:proposal_photos, Decidim::Dev.asset("city.jpeg"))

            within ".edit_proposal" do
              find("*[type=submit]").click
            end

            click_button "Publish"

            expect(page).to have_content("successfully")

            within ".section.images" do
              expect(page).to have_selector("img[src*=\"city.jpeg\"]", count: 1)
            end
          end

          context "with multiple images" do
            before do
              visit complete_proposal_path(component, proposal_draft)

              within ".edit_proposal" do
                fill_in :proposal_title, with: "Proposal with attachments"
                fill_in :proposal_body, with: "This is my proposal and I want to upload attachments."
              end
            end

            it "sets the card image correctly with zero weight" do
              # Attach one card image and two document images and go to preview
              dynamically_attach_file(:proposal_photos, Decidim::Dev.asset("city.jpeg"))
              dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city2.jpeg"))
              dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city3.jpeg"))

              within ".edit_proposal" do
                find("*[type=submit]").click
              end

              # From preview, go back to edit
              expect(page).to have_content("Your proposal has not yet been published")
              click_link "Modify the proposal"

              # See that the images are in correct positions and remove the card
              # image.
              within ".dynamic-uploads.upload-container-for-photos .active-uploads" do
                expect(page).to have_content("city.jpeg")
              end
              within ".dynamic-uploads.upload-container-for-documents .active-uploads" do
                expect(page).to have_content("city2.jpeg")
                expect(page).to have_content("city3.jpeg")
              end

              within ".dynamic-uploads.upload-container-for-photos" do
                click_button "Edit image"
              end
              within ".upload-modal" do
                find("button.remove-upload-item").click
                click_button "Save"
              end

              within ".edit_proposal" do
                find("*[type=submit]").click
              end

              # From preview, go back to edit
              expect(page).to have_content("Your proposal has not yet been published")
              click_link "Modify the proposal"

              # See that the card image is now empty and the two other images
              # are still in the documents container as they should.
              within ".dynamic-uploads.upload-container-for-photos .active-uploads" do
                expect(page).not_to have_selector(".attachment-details")
              end
              within ".dynamic-uploads.upload-container-for-documents .active-uploads" do
                expect(page).to have_content("city2.jpeg")
                expect(page).to have_content("city3.jpeg")
              end
            end
          end
        end
      end

      context "when creation is not enabled" do
        it "does not show the creation button" do
          visit_component
          expect(page).to have_no_link("New proposal")
        end
      end

      context "when the proposal limit is 1" do
        let!(:component) do
          create(:proposal_component,
                 :with_creation_enabled,
                 :with_proposal_limit,
                 manifest:,
                 participatory_space: participatory_process)
        end

        let!(:proposal_first) { create(:proposal, users: [user], component:, title: "Creating my first and only proposal", body: "This is my only proposal's body and I'm using it unwisely.") }

        before do
          visit_component
          click_link "New proposal"
        end

        it "allows the creation of a single new proposal" do
          within ".new_proposal" do
            fill_in :proposal_title, with: "Creating my second proposal"
            fill_in :proposal_body, with: "This is my second proposal's body and I'm using it unwisely."

            find("*[type=submit]").click
          end

          expect(page).to have_no_content("successfully")
          expect(page).to have_css(".callout.alert", text: "limit")
        end
      end
    end
  end
end

def complete_proposal_path(component, proposal)
  "#{Decidim::EngineRouter.main_proxy(component).proposal_path(proposal)}/complete"
end
