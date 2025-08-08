# frozen_string_literal: true

require "spec_helper"

describe "Collaborative drafts" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: [participatory_process.manifest.name]) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:taxonomy_filter_ids) { [taxonomy_filter.id] }

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
                   taxonomy_filters: taxonomy_filter_ids
                 })
        end

        it "creates a new collaborative draft", :slow do
          visit new_collaborative_draft_path

          within ".new_collaborative_draft" do
            fill_in :collaborative_draft_title, with: "More sidewalks and less roads"
            fill_in :collaborative_draft_body, with: "Cities need more people, not more cars"
            select decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}"

            find("*[type=submit]").click
          end

          expect(page).to have_content("successfully")
          expect(page).to have_content("More sidewalks and less roads")
          expect(page).to have_content("Cities need more people, not more cars")
          expect(page).to have_content(decidim_sanitize_translated(taxonomy.name))
          expect(page).to have_author(user.name)
        end

        context "when no taxonomy filter is selected" do
          let(:taxonomy_filter_ids) { [] }

          it "creates a proposal without taxonomies" do
            visit new_collaborative_draft_path

            within ".new_collaborative_draft" do
              fill_in :collaborative_draft_title, with: "More sidewalks and less roads"
              fill_in :collaborative_draft_body, with: "Cities need more people, not more cars"
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

        context "when geocoding is enabled" do
          let!(:component) do
            create(:proposal_component,
                   :with_creation_enabled,
                   manifest:,
                   participatory_space: participatory_process)
          end

          before do
            component.update!(settings: {
                                geocoding_enabled: true,
                                collaborative_drafts_enabled: true
                              })
          end

          it "creates a new collaborative draft", :slow do
            visit new_collaborative_draft_path

            within ".new_collaborative_draft" do
              fill_in :collaborative_draft_title, with: "More sidewalks and less roads"
              fill_in :collaborative_draft_body, with: "Cities need more people, not more cars"
              fill_in_geocoding :collaborative_draft_address, with: address

              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")
            expect(page).to have_content("More sidewalks and less roads")
            expect(page).to have_content("Cities need more people, not more cars")
            expect(page).to have_content(address)
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
