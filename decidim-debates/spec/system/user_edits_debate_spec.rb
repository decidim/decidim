# frozen_string_literal: true

require "spec_helper"

describe "User edits a debate" do
  include_context "with a component"
  include_context "with taxonomy filters context"
  let(:manifest_name) { "debates" }
  let(:attachments_allowed) { false }
  let(:participatory_space_manifests) { [participatory_process.manifest.name] }
  let(:taxonomies) { [taxonomy] }
  let!(:debate) do
    create(
      :debate,
      author:,
      component:
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    component_settings = component["settings"]["global"].merge!(taxonomy_filters: [taxonomy_filter.id], attachments_allowed:)
    component.update!(settings: component_settings)
  end

  context "when editing my debate" do
    let(:user) { create(:user, :confirmed, organization:) }
    let(:author) { user }

    it "allows editing my debate", :slow do
      visit_component

      click_on debate.title.values.first
      find("#dropdown-trigger-resource-#{debate.id}").click
      click_on "Edit"

      within ".edit_debate" do
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

    context "when attachments are disallowed" do
      it "does not show the attachments form" do
        visit_component

        click_on debate.title.values.first
        find("#dropdown-trigger-resource-#{debate.id}").click
        click_on "Edit"

        expect(page).to have_no_css("#debate_documents_button")
      end
    end

    context "when attachments are allowed", :slow do
      let(:attachments_allowed) { true }
      let(:image_filename) { "city2.jpeg" }
      let(:image_path) { Decidim::Dev.asset(image_filename) }
      let(:document_filename) { "Exampledocument.pdf" }
      let(:document_path) { Decidim::Dev.asset(document_filename) }

      before do
        visit_component
        click_on debate.title.values.first
        find("#dropdown-trigger-resource-#{debate.id}").click
        click_on "Edit"
      end

      it "allows editing my debate", :slow do
        within ".edit_debate" do
          fill_in :debate_title, with: "Should every organization use Decidim?"
          fill_in :debate_description, with: "Add your comments on whether Decidim is useful for every organization."
        end

        dynamically_attach_file(:debate_documents, image_path)
        dynamically_attach_file(:debate_documents, document_path)

        within ".edit_debate" do
          find("*[type=submit]").click
        end

        expect(page).to have_content("successfully")
        expect(page).to have_css("[data-author]", text: user.name)
        expect(page).to have_css("img[src*='#{image_filename}']")

        click_on "Documents"

        expect(page).to have_css("a[href*='#{document_filename}']")
        expect(page).to have_content("Download file", count: 1)
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
  end
end
