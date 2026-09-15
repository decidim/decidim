# frozen_string_literal: true

require "spec_helper"

describe "User manages posts" do
  include_context "with a component"

  let(:manifest_name) { "blogs" }
  let(:post) { create(:post, component:) }
  let!(:user) { create(:user, :confirmed, organization:) }

  let!(:component) { create(:post_component, :with_attachments_allowed_and_creation_enabled, manifest:, participatory_space: participatory_process) }

  before do
    switch_to_host(organization.host)
  end

  context "with creation disabled" do
    let!(:component) { create(:post_component, manifest:, participatory_space: participatory_process) }

    it "cannot see the new post button" do
      visit_component

      expect(page).to have_no_text "New post"
    end
  end

  context "when not signed in" do
    it "new post button redirects to login" do
      visit_component

      click_on "New post"
      expect(page).to have_text "Please log in"
    end
  end

  context "when signed in as a regular user" do
    before do
      login_as user, scope: :user
    end

    context "with an empty form" do
      it "allows submission and show errors" do
        visit_component
        click_on "New post"

        expect(page).to have_no_css("*[type=submit][data-disable='true']")

        within ".new_post" do
          find("*[type=submit]").click

          expect(page).to have_css("div.sr-announce")
          within "div.sr-announce" do
            expect(page).to have_text("There are errors on the form, please correct them to continue.")
          end

          expect(page).to have_text("There is an error in this field.")
          expect(page).to have_no_css("*[type=submit][data-disable='true']")
          expect(find("button[type='submit']")).not_to be_disabled
        end
      end
    end

    context "when creating a post" do
      it "saves the data" do
        visit_component

        click_on "New post"
        expect(page).to have_text "Create new post"

        fill_in "post_title", with: "My post"
        fill_in "post_body", with: "This is my post"
        dynamically_attach_file(:post_attachments, Decidim::Dev.asset("city.jpeg"))
        click_on "Create"

        expect(page).to have_text "My post"
        expect(page).to have_css("img[src*=\"city.jpeg\"]")
      end
    end

    context "when editing an authored a post" do
      let!(:post) { create(:post, component:, author: user) }

      context "and empties the form" do
        it "allows submission and show errors" do
          visit_component

          click_on translated(post.title)
          find("#dropdown-trigger-resource-#{post.id}").click
          click_on "Edit post"

          expect(page).to have_no_css("*[type=submit][data-disable='true']")

          fill_in "post_title", with: ""

          within ".edit_post" do
            find("*[type=submit]").click

            expect(page).to have_css("div.sr-announce")
            within "div.sr-announce" do
              expect(page).to have_text("There are errors on the form, please correct them to continue.")
            end

            expect(page).to have_text("There is an error in this field.")
            expect(page).to have_no_css("*[type=submit][data-disable='true']")
            expect(find("button[type='submit']")).not_to be_disabled
          end
        end
      end

      it "can edit the post" do
        visit_component

        click_on translated(post.title)
        find("#dropdown-trigger-resource-#{post.id}").click
        click_on "Edit post"

        expect(page).to have_text "Edit post"

        fill_in "post_title", with: "My edited post"
        click_on "Update"

        expect(page).to have_text "My edited post"
      end

      it "can delete the post" do
        visit_component

        click_on translated(post.title)
        find("#dropdown-trigger-resource-#{post.id}").click
        click_on "Delete post"

        expect(page).to have_text("Are you sure you want to delete this post?")

        click_on "OK"

        expect(page).to have_text "Post deleted successfully"
      end
    end
  end
end
