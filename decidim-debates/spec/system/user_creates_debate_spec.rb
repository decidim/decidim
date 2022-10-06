# frozen_string_literal: true

require "spec_helper"

describe "User creates debate", type: :system do
  include_context "with a component"
  let(:manifest_name) { "debates" }

  before do
    switch_to_host(organization.host)
  end

  context "when creating a new debate" do
    let(:user) { create :user, :confirmed, organization: }
    let!(:category) { create :category, participatory_space: }

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "with creation enabled" do
        let!(:component) do
          create(:debates_component,
                 :with_creation_enabled,
                 participatory_space: participatory_process)
        end

        context "and rich_editor_public_view component setting is enabled" do
          before do
            organization.update(rich_text_editor_in_public_views: true)
            visit_component
            click_link "New debate"
          end

          it_behaves_like "having a rich text editor", "new_debate", "basic"
        end

        it "creates a new debate", :slow do
          visit_component

          click_link "New debate"

          within ".new_debate" do
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

        context "when creating as a user group" do
          let!(:user_group) { create :user_group, :verified, organization:, users: [user] }

          it "creates a new debate", :slow do
            visit_component

            click_link "New debate"

            within ".new_debate" do
              fill_in :debate_title, with: "Should every organization use Decidim?"
              fill_in :debate_description, with: "Add your comment on whether Decidim is useful for every organization."
              select translated(category.name), from: :debate_category_id
              select user_group.name, from: :debate_user_group_id

              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")
            expect(page).to have_content("Should every organization use Decidim?")
            expect(page).to have_content("Add your comment on whether Decidim is useful for every organization.")
            expect(page).to have_content(translated(category.name))
            expect(page).to have_selector(".author-data", text: user_group.name)
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
            click_link "New debate"
            expect(page).to have_content("Authorization required")
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
