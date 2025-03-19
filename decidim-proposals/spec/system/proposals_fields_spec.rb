# frozen_string_literal: true

require "spec_helper"

describe "Proposals" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:taxonomy_filter_ids) { [taxonomy_filter.id] }

  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  let(:proposal_title) { "More sidewalks and less roads" }
  let(:proposal_body) { "Cities need more people, not more cars" }

  before do
    stub_geocoding(address, [latitude, longitude])
  end

  matcher :have_author do |name|
    match { |node| node.has_selector?("[data-author]", text: name) }
    match_when_negated { |node| node.has_no_selector?("[data-author]", text: name) }
  end

  context "when creating a new proposal" do
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
                 settings: { taxonomy_filters: taxonomy_filter_ids })
        end

        let(:proposal_draft) { create(:proposal, :draft, component:, users: [user]) }

        it "creates a new proposal", :slow do
          visit edit_draft_proposal_path(component, proposal_draft)

          within ".edit_proposal" do
            fill_in :proposal_title, with: "More sidewalks and less roads"
            fill_in :proposal_body, with: "Cities need more people, not more cars"
            select decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}"

            find("*[type=submit]").click
          end

          expect(page).to have_no_css(".address__info")
          expect(page).to have_no_css(".address__map")

          click_on "Publish"

          expect(page).to have_content("successfully")
          expect(page).to have_content("More sidewalks and less roads")
          expect(page).to have_content("Cities need more people, not more cars")
          expect(page).to have_content(decidim_sanitize_translated(taxonomy.name))
          expect(page).to have_author(user.name)
        end

        context "when no taxonomy filter is selected" do
          let(:taxonomy_filter_ids) { [] }

          it "creates a proposal without taxonomies" do
            visit edit_draft_proposal_path(component, proposal_draft)

            within ".edit_proposal" do
              fill_in :proposal_title, with: "More sidewalks and less roads"
              fill_in :proposal_body, with: "Cities need more people, not more cars"
              expect(page).to have_no_content(decidim_sanitize_translated(root_taxonomy.name))

              find("*[type=submit]").click
            end

            click_on "Publish"

            expect(page).to have_content("successfully")
            expect(page).to have_content("More sidewalks and less roads")
            expect(page).to have_content("Cities need more people, not more cars")
            expect(page).to have_no_content(decidim_sanitize_translated(taxonomy.name))
            expect(page).to have_author(user.name)
          end
        end

        context "when geocoding is enabled", :serves_geocoding_autocomplete do
          let!(:component) do
            create(:proposal_component,
                   :with_creation_enabled,
                   manifest:,
                   participatory_space: participatory_process,
                   settings: {
                     geocoding_enabled: true,
                     taxonomy_filters: taxonomy_filter_ids
                   })
          end

          let(:proposal_draft) { create(:proposal, :draft, users: [user], component:, title: "More sidewalks and less roads", body: "It will not solve everything") }

          it "creates a new proposal", :slow do
            visit edit_draft_proposal_path(component, proposal_draft)

            within ".edit_proposal" do
              fill_in :proposal_title, with: "More sidewalks and less roads"
              fill_in :proposal_body, with: "Cities need more people, not more cars"
              fill_in_geocoding :proposal_address, with: address

              expect(page).to have_css("[data-decidim-map]")
              expect(page).to have_content("You can move the point on the map.")

              select decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}"

              find("*[type=submit]").click
            end

            within ".static-map__container" do
              expect(page).to have_css(".static-map")
            end

            click_on "Publish"

            expect(page).to have_content("successfully")
            expect(page).to have_content("More sidewalks and less roads")
            expect(page).to have_content("Cities need more people, not more cars")
            expect(page).to have_content(address)
            expect(page).to have_content(decidim_sanitize_translated(taxonomy.name))
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
              visit edit_draft_proposal_path(component, proposal_draft)

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
            visit edit_draft_proposal_path(component, proposal_draft)

            within ".edit_proposal" do
              check :proposal_suggested_hashtags_suggestedhashtag1

              find("*[type=submit]").click
            end

            click_on "Publish"

            expect(page).to have_content("successfully")
            expect(page).to have_content("#AutoHashtag1")
            expect(page).to have_content("#AutoHashtag2")
            expect(page).to have_content("#SuggestedHashtag1")
            expect(page).to have_no_content("#SuggestedHashtag2")
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
              click_on "New proposal"
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
              click_on "New proposal"
              expect(page).to have_content("You are almost ready to create a proposal")
              expect(page).to have_css("a[data-verification]", count: 2)
            end
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

          let(:proposal_draft) do
            create(:proposal, :draft, users: [user], component:, title: "Proposal with attachments", body: "This is my proposal and I want to upload attachments.")
          end

          it "creates a new proposal with attachments" do
            visit edit_draft_proposal_path(component, proposal_draft)

            within ".edit_proposal" do
              fill_in :proposal_title, with: "Proposal with attachments"
              fill_in :proposal_body, with: "This is my proposal and I want to upload attachments."
            end

            dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city.jpeg"))

            within ".edit_proposal" do
              find("*[type=submit]").click
            end

            click_on "Publish"

            expect(page).to have_content("successfully")
            expect(page).to have_content("Images")

            within "#panel-images" do
              expect(page).to have_css("img[src*=\"city.jpeg\"]", count: 1)
            end
          end

          context "with multiple images" do
            before do
              visit edit_draft_proposal_path(component, proposal_draft)

              within ".edit_proposal" do
                fill_in :proposal_title, with: "Proposal with attachments"
                fill_in :proposal_body, with: "This is my proposal and I want to upload attachments."
              end
            end

            it "sets the card image correctly with zero weight", :slow do
              skip "REDESIGN_PENDING - Flaky test: upload modal fails on GitHub with multiple files https://github.com/decidim/decidim/issues/10961"

              # Attach one card image and two document images and go to preview
              dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city.jpeg"))
              expect(page).to have_content("city.jpeg")
              dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city2.jpeg"))
              expect(page).to have_content("city.jpeg")
              expect(page).to have_content("city2.jpeg")
              dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city3.jpeg"))
              expect(page).to have_content("city.jpeg")
              expect(page).to have_content("city2.jpeg")
              expect(page).to have_content("city3.jpeg")

              within ".edit_proposal" do
                find("*[type=submit]").click
              end

              # From preview, go back to edit
              expect(page).to have_content("Your proposal has not yet been published")
              click_on "Modify the proposal"

              # See that the images are in correct positions and remove the card
              # image.
              within "[data-active-uploads]" do
                expect(page).to have_content("city.jpeg")
                expect(page).to have_content("city2.jpeg")
                expect(page).to have_content("city3.jpeg")
              end

              within ".upload-container-for-documents" do
                click_on "Edit documents"
              end
              within ".upload-modal" do
                within "[data-filename='city.jpeg']" do
                  click_on("Remove")
                end
                click_on "Next"
              end

              within ".edit_proposal" do
                find("*[type=submit]").click
              end

              # From preview, go back to edit
              expect(page).to have_content("Your proposal has not yet been published")
              click_on "Modify the proposal"

              within "[data-active-uploads]" do
                expect(page).to have_no_content("city.jpeg")
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

        let!(:proposal_first) do
          create(:proposal, users: [user], component:, title: "Creating my first and only proposal", body: "This is my only proposal's body and I am using it unwisely.")
        end

        before do
          visit_component
          click_on "New proposal"
        end

        it "allows the creation of a single new proposal" do
          within ".new_proposal" do
            fill_in :proposal_title, with: "Creating my second proposal"
            fill_in :proposal_body, with: "This is my second proposal's body and I am using it unwisely."

            find("*[type=submit]").click
          end

          expect(page).to have_no_content("successfully")
          expect(page).to have_css("[data-alert-box].alert", text: "limit")
        end
      end
    end
  end
end

def edit_draft_proposal_path(component, proposal)
  "#{Decidim::EngineRouter.main_proxy(component).proposal_path(proposal)}/edit_draft"
end
