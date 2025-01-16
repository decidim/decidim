# frozen_string_literal: true

require "spec_helper"

describe "User creates debate" do
  include_context "with a component"
  include_context "with taxonomy filters context"
  let(:manifest_name) { "debates" }
  let(:space_manifest) { participatory_process.manifest.name }
  let(:taxonomies) { [taxonomy] }

  before do
    switch_to_host(organization.host)
  end

  context "when creating a new debate" do
    let(:user) { create(:user, :confirmed, organization:) }

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "with creation enabled" do
        let!(:component) do
          create(:debates_component,
                 :with_creation_enabled,
                 participatory_space: participatory_process,
                 settings: { taxonomy_filters: [taxonomy_filter.id] })
        end

        context "and attachments are not allowed" do
          before do
            component_settings = component["settings"]["global"].merge!(attachments_allowed: false)
            component.update!(settings: component_settings)
            visit_component
            click_on "New debate"
          end

          it "does not show the attachments form" do
            expect(page).to have_no_css("#debate_documents_button")
          end
        end

        context "and attachments are allowed" do
          let(:attachments_allowed) { true }
          let(:image_filename) { "city2.jpeg" }
          let(:image_path) { Decidim::Dev.asset(image_filename) }
          let(:document_filename) { "Exampledocument.pdf" }
          let(:document_path) { Decidim::Dev.asset(document_filename) }

          before do
            component_settings = component["settings"]["global"].merge!(attachments_allowed: true)
            component.update!(settings: component_settings)
            visit_component
            click_on "New debate"
          end

          it "creates a new debate" do
            within ".new_debate" do
              fill_in :debate_title, with: "Should every organization use Decidim?"
              fill_in :debate_description, with: "Add your comments on whether Decidim is useful for every organization."
            end

            dynamically_attach_file(:debate_documents, image_path)
            dynamically_attach_file(:debate_documents, document_path)

            within ".new_debate" do
              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")
            expect(page).to have_content("Should every organization use Decidim?")
            expect(page).to have_content("Add your comments on whether Decidim is useful for every organization.")
            expect(page).to have_css("[data-author]", text: user.name)
            expect(page).to have_css("img[src*='#{image_filename}']")

            click_on "Documents"

            expect(page).to have_css("a[href*='#{document_filename}']")
            expect(page).to have_content("Download file", count: 1)
          end

          it "shows validation error when format is not accepted" do
            dynamically_attach_file(:debate_documents, Decidim::Dev.asset("dummy-dummies-example.xlsx"), keep_modal_open: true) do
              expect(page).to have_content("Accepted formats: #{Decidim::OrganizationSettings.for(organization).upload_allowed_file_extensions.join(", ")}")
            end
            expect(page).to have_content("Validation error!")
          end

          context "when attaching an invalid file format" do
            it "shows an error message" do
              dynamically_attach_file(:debate_documents, Decidim::Dev.asset("participatory_text.odt"), keep_modal_open: true) do
                expect(page).to have_content("Accepted formats: #{Decidim::OrganizationSettings.for(organization).upload_allowed_file_extensions.join(", ")}")
              end
              expect(page).to have_content("Validation error! Check that the file has an allowed extension or size.")
            end
          end
        end

        context "and rich_editor_public_view component setting is enabled" do
          before do
            organization.update(rich_text_editor_in_public_views: true)
            visit_component
            click_on "New debate"
          end

          it_behaves_like "having a rich text editor", "new_debate", "basic"
        end

        it "creates a new debate", :slow do
          visit_component

          click_on "New debate"

          within ".new_debate" do
            fill_in :debate_title, with: "Should every organization use Decidim?"
            fill_in :debate_description, with: "Add your comments on whether Decidim is useful for every organization."
            select decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}"

            find("*[type=submit]").click
          end

          expect(page).to have_content("successfully")
          expect(page).to have_content("Should every organization use Decidim?")
          expect(page).to have_content("Add your comments on whether Decidim is useful for every organization.")
          expect(page).to have_content(decidim_sanitize_translated(taxonomy.name))
          expect(page).to have_css("[data-author]", text: user.name)
        end

        context "when creating as a user group" do
          let!(:user_group) { create(:user_group, :verified, organization:, users: [user]) }

          it "creates a new debate", :slow do
            visit_component

            click_on "New debate"

            within ".new_debate" do
              fill_in :debate_title, with: "Should every organization use Decidim?"
              fill_in :debate_description, with: "Add your comment on whether Decidim is useful for every organization."
              select decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}"
              select user_group.name, from: :debate_user_group_id

              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")
            expect(page).to have_content("Should every organization use Decidim?")
            expect(page).to have_content("Add your comment on whether Decidim is useful for every organization.")
            expect(page).to have_content(decidim_sanitize_translated(taxonomy.name))
            expect(page).to have_css("[data-author]", text: user_group.name)
          end
        end

        context "when the user is not authorized" do
          let!(:organization) { create(:organization, *organization_traits, available_authorizations: %w(dummy_authorization_handler another_dummy_authorization_handler)) }

          context "when there is only an authorization required" do
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
              click_on "New debate"

              expect(page).to have_content("We need to verify your identity")
              expect(page).to have_content("Verify with Example authorization")
            end
          end

          context "when there are more than one authorization required" do
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
              click_on "New debate"

              expect(page).to have_content("You are almost ready to create a debate")
              expect(page).to have_css("a[data-verification]", count: 2)
            end
          end
        end
      end

      context "when creation is not enabled" do
        it "does not show the creation button" do
          visit_component
          expect(page).to have_no_link("New debate")
        end
      end
    end
  end
end
