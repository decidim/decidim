# frozen_string_literal: true

require "spec_helper"

describe "User edits a debate", type: :system do
  include_context "with a component"

  let(:manifest_name) { "debates" }
  let!(:debate) do
    create(
      :debate,
      author:,
      component:,
      skip_injection: true
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    component_scope = create :scope, parent: component.participatory_space.scope
    component_settings = component["settings"]["global"].merge!(scopes_enabled: true, scope_id: component_scope.id)
    component.update!(settings: component_settings)
  end

  context "when editing my debate" do
    let(:user) { create :user, :confirmed, organization: }
    let(:author) { user }
    let!(:scope) { create(:scope, organization:) }
    let!(:category) { create :category, participatory_space: }
    let(:scope_picker) { select_data_picker(:debate_scope_id) }

    it "allows editing my debate", :slow do
      visit_component

      click_link debate.title.values.first
      click_link "Edit debate"

      within ".edit_debate" do
        fill_in :debate_title, with: "Should every organization use Decidim?"
        fill_in :debate_description, with: "Add your comments on whether Decidim is useful for every organization."
        scope_pick scope_picker, scope
        select translated(category.name), from: :debate_category_id

        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")
      expect(page).to have_content("Should every organization use Decidim?")
      expect(page).to have_content("Add your comments on whether Decidim is useful for every organization.")
      expect(page).to have_content(translated(scope.name))
      expect(page).to have_content(translated(category.name))
      expect(page).to have_selector(".author-data", text: user.name)
    end

    context "when editing as a user group" do
      let(:author) { user }
      let!(:user_group) { create :user_group, :verified, organization:, users: [user] }
      let!(:debate) do
        create(
          :debate,
          author:,
          user_group:,
          component:,
          skip_injection: true
        )
      end

      it "edits their debate", :slow do
        visit_component
        click_link debate.title.values.first
        click_link "Edit debate"

        within ".edit_debate" do
          fill_in :debate_title, with: "Should every organization use Decidim?"
          fill_in :debate_description, with: "Add your comment on whether Decidim is useful for every organization."
          scope_pick scope_picker, scope
          select translated(category.name), from: :debate_category_id

          find("*[type=submit]").click
        end

        expect(page).to have_content("successfully")
        expect(page).to have_content("Should every organization use Decidim?")
        expect(page).to have_content("Add your comment on whether Decidim is useful for every organization.")
        expect(page).to have_content(translated(scope.name))
        expect(page).to have_content(translated(category.name))
        expect(page).to have_selector(".author-data", text: user_group.name)
      end
    end
  end
end
