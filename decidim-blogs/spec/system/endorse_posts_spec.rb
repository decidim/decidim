# frozen_string_literal: true

require "spec_helper"

describe "endorse posts", type: :system do
  include_context "with a component"
  let(:manifest_name) { "blogs" }
  let(:organization) { create(:organization) }
  let(:author) { create(:user, :confirmed, name: "Tester", organization: organization) }
  let!(:post) { create(:post, component: component, title: { en: "Blog post title" }) }

  before do
    sign_in author
    visit_component
    click_link "Blog post title"
  end

  context "when liking the post without belonging to a user group" do
    it "likes the post" do
      click_button("Endorse")
      expect(page).to have_content("ENDORSED")
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
        organization: organization
      )
    end

    it "opens a modal where you select identity as a user or a group" do
      visit page.current_path
      click_button("Endorse")
      expect(page).to have_content("SELECT IDENTITY")
      expect(page).to have_content("Tester's Organization")
      expect(page).to have_content("Tester")
    end

    def add_likes
      click_button "Endorse"
      within "#user-identities" do
        find("li", text: /\ATester's Organization\z/).click
        find("li", text: /\ATester\z/).click
        click_button "Done"
      end
      visit current_path
      click_button "Endorse"
    end

    context "when both identities picked" do
      it "likes the post as a group and a user" do
        visit page.current_path

        add_likes

        within "#user-identities" do
          expect(page).to have_css(".selected", count: 2)
        end
      end
    end

    context "when like cancelled as a user" do
      it "doesn't cancel group like" do
        visit page.current_path

        add_likes
        find(".selected", match: :first).click
        click_button "Done"
        visit current_path
        click_button "Endorse"

        within "#user-identities" do
          expect(page).to have_css(".selected", count: 1)
          within ".selected" do
            expect(page).to have_text("Tester's Organization", exact: true)
          end
        end
      end
    end

    context "when like cancelled as a group" do
      it "doesn't cancel user like" do
        visit page.current_path

        add_likes
        page.all(".selected")[1].click
        click_button "Done"
        visit current_path
        click_button "Endorse"

        within "#user-identities" do
          expect(page).to have_css(".selected", count: 1)
          within ".selected" do
            expect(page).to have_text("Tester", exact: true)
          end
        end
      end
    end
  end
end
