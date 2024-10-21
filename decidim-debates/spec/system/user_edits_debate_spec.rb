# frozen_string_literal: true

require "spec_helper"

describe "User edits a debate" do
  include_context "with a component"

  let(:manifest_name) { "debates" }
  let(:attachments_allowed) { false }
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
    component_scope = create(:scope, parent: component.participatory_space.scope)
    component_settings = component["settings"]["global"].merge!(scopes_enabled: true, scope_id: component_scope.id, attachments_allowed:)
    component.update!(settings: component_settings)
  end

  context "when editing my debate" do
    let(:user) { create(:user, :confirmed, organization:) }
    let(:author) { user }
    let!(:scope) { create(:scope, organization:) }
    let!(:category) { create(:category, participatory_space:) }

    context "when attachments are disallowed" do
      it "does not show the attachments form", :slow do
        visit_component

        click_on debate.title.values.first
        click_on "Edit debate"

        expect(page).to have_no_css("#debate_documents_button")
      end
    end

    context "when attachments are allowed" do
      let(:attachments_allowed) { true }
      let(:image_filename) { "city2.jpeg" }
      let(:image_path) { Decidim::Dev.asset(image_filename) }
      let(:document_filename) { "Exampledocument.pdf" }
      let(:document_path) { Decidim::Dev.asset(document_filename) }

      it "allows editing my debate", :slow do
        visit_component

        click_on debate.title.values.first
        click_on "Edit debate"

        within ".edit_debate" do
          fill_in :debate_title, with: "Should every organization use Decidim?"
          fill_in :debate_description, with: "Add your comments on whether Decidim is useful for every organization."
          select translated(scope.name), from: :debate_scope_id
          select translated(category.name), from: :debate_category_id
        end

        dynamically_attach_file(:debate_documents, image_path)
        dynamically_attach_file(:debate_documents, document_path)

        within ".edit_debate" do
          find("*[type=submit]").click
        end

        expect(page).to have_content("successfully")
        expect(page).to have_content("Should every organization use Decidim?")
        expect(page).to have_content("Add your comments on whether Decidim is useful for every organization.")
        expect(page).to have_content(translated(scope.name))
        expect(page).to have_content(translated(category.name))
        expect(page).to have_css("[data-author]", text: user.name)
        expect(page).to have_css("img[src*='#{image_filename}']")

        click_on "Documents"

        expect(page).to have_css("a[href*='#{document_filename}']")
        expect(page).to have_content("Download file", count: 1)
      end
    end

    context "when editing as a user group" do
      let(:author) { user }
      let!(:user_group) { create(:user_group, :verified, organization:, users: [user]) }
      let!(:debate) do
        create(
          :debate,
          author:,
          user_group:,
          component:
        )
      end

      it "edits their debate", :slow do
        visit_component
        click_on debate.title.values.first
        click_on "Edit debate"

        within ".edit_debate" do
          fill_in :debate_title, with: "Should every organization use Decidim?"
          fill_in :debate_description, with: "Add your comment on whether Decidim is useful for every organization."
          select translated(scope.name), from: :debate_scope_id
          select translated(category.name), from: :debate_category_id

          find("*[type=submit]").click
        end

        expect(page).to have_content("successfully")
        expect(page).to have_content("Should every organization use Decidim?")
        expect(page).to have_content("Add your comment on whether Decidim is useful for every organization.")
        expect(page).to have_content(translated(scope.name))
        expect(page).to have_content(translated(category.name))
        expect(page).to have_css("[data-author]", text: user_group.name)
      end
    end
  end
end
