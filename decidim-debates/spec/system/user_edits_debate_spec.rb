# frozen_string_literal: true

require "spec_helper"

describe "User edits a debate", type: :system do
  include_context "with a component"

  let(:manifest_name) { "debates" }
  let!(:debate) do
    create(
      :debate,
      author: author,
      component: component
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when editing my debate" do
    let(:user) { create :user, :confirmed, organization: organization }
    let(:author) { user }
    let!(:category) { create :category, participatory_space: participatory_space }

    it "allows editing my debate", :slow do
      visit_component

      click_link debate.title.values.first
      click_link "Edit debate"

      within ".edit_debate" do
        fill_in :debate_title, with: "Should every organization use Decidim?"
        fill_in :debate_description, with: "Add your comments on whether Decidim is useful for every organization."
        select translated(category.name), from: :debate_category_id

        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")
      expect(page).to have_content("Should every organization use Decidim?")
      expect(page).to have_content("Add your comments on whether Decidim is useful for every organization.")
      expect(page).to have_content(translated(category.name))
      expect(page).to have_selector(".author-data", text: user.name)
    end

    context "when editing as a user group" do
      let(:author) { user }
      let!(:user_group) { create :user_group, :verified, organization: organization, users: [user] }
      let!(:debate) do
        create(
          :debate,
          author: author,
          user_group: user_group,
          component: component
        )
      end

      it "edits their debate", :slow do
        visit_component
        click_link debate.title.values.first
        click_link "Edit debate"

        within ".edit_debate" do
          fill_in :debate_title, with: "Should every organization use Decidim?"
          fill_in :debate_description, with: "Add your comment on whether Decidim is useful for every organization."
          select translated(category.name), from: :debate_category_id

          find("*[type=submit]").click
        end

        expect(page).to have_content("successfully")
        expect(page).to have_content("Should every organization use Decidim?")
        expect(page).to have_content("Add your comment on whether Decidim is useful for every organization.")
        expect(page).to have_content(translated(category.name))
        expect(page).to have_selector(".author-data", text: user_group.name)
      end
    end
  end
end
