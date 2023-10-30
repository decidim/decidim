# frozen_string_literal: true

require "spec_helper"

describe "endorse posts" do
  include_context "with a component"
  let(:manifest_name) { "blogs" }
  let(:organization) { create(:organization) }
  let(:author) { create(:user, :confirmed, name: "Tester", organization:) }
  let!(:post) { create(:post, component:, title: { en: "Blog post title" }) }

  before do
    sign_in author
  end

  context "when liking the post without belonging to a user group" do
    it "likes the post" do
      visit_component
      click_link "Blog post title"
      click_button "Like"

      expect(page).to have_content("Dislike")
    end
  end

  context "when liking the post while being a part of a group" do
    let!(:user_group) do
      create(
        :user_group,
        :verified,
        name: "Tester's Organization",
        nickname: "test_org",
        email: "t.mail.org@example.org",
        users: [author],
        organization:
      )
    end

    before do
      visit_component
      click_link "Blog post title"
    end

    it "opens a modal where you select identity as a user or a group" do
      click_button "Like"
      expect(page).to have_content("Select identity")
      expect(page).to have_content("Tester's Organization")
      expect(page).to have_content("Tester")
    end

    def add_likes
      click_button "Like"
      click_button "Tester's Organization"
      click_button "Tester"
      click_button "Done"
      visit current_path
      click_button "Dislike"
    end

    context "when both identities picked" do
      it "likes the post as a group and a user" do
        add_likes

        within ".identities-modal__list" do
          expect(page).to have_css(".is-selected", count: 2)
        end
      end
    end

    context "when like cancelled as a user" do
      it "does not cancel group like" do
        add_likes
        find(".is-selected", match: :first).click
        click_button "Done"
        visit current_path
        click_button "Like"

        within ".identities-modal__list" do
          expect(page).to have_css(".is-selected", count: 1)
          within ".is-selected" do
            expect(page).to have_content("Tester's Organization")
          end
        end
      end
    end

    context "when like cancelled as a group" do
      it "does not cancel user like" do
        add_likes
        page.all(".is-selected")[1].click
        click_button "Done"
        visit current_path
        click_button "Dislike"

        within ".identities-modal__list" do
          expect(page).to have_css(".is-selected", count: 1)
          within ".is-selected" do
            expect(page).to have_text("Tester", exact: true)
          end
        end
      end
    end
  end
end
