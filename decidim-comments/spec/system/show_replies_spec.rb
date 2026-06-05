# frozen_string_literal: true

require "spec_helper"

describe "Show replies" do
  let!(:organization) { create(:organization) }
  let!(:component) { create(:component, manifest_name: :dummy, organization:) }
  let!(:commentable) { create(:dummy_resource, component:) }
  let!(:comment) { create(:comment, commentable:) }
  let!(:replies) { create_list(:comment, 3, commentable: comment, root_commentable: commentable) }

  let(:resource_path) { resource_locator(commentable).path }

  before do
    switch_to_host(organization.host)
    visit resource_path
  end

  after do
    expect_no_js_errors
  end

  context "when viewing a comment with replies" do
    it "shows the replies button with the correct count" do
      expect(page).to have_text("3 replies")
    end

    it "loads the replies when clicking the button", :slow do
      click_button "3 replies"

      expect(page).to have_css(".comment-thread .comment", count: 4)
    end
  end

  context "when replying to a loaded comment" do
    let!(:organization) { create(:organization) }
    let!(:component) { create(:component, manifest_name: :dummy, organization:) }
    let!(:commentable) { create(:dummy_resource, component:) }
    let!(:comments) { create_list(:comment, 30, commentable:) }
    let!(:user) { create(:user, :confirmed, organization:) }

    let(:resource_path) { resource_locator(commentable).path }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit resource_path
    end

    after do
      expect_no_js_errors
    end

    it "shows comments after loading more", :slow do
      expect(page).to have_text("Load more comments")

      click_button "Load more comments"

      expect(page).to have_css(".comment")
    end

    it "can reply to a loaded comment", :slow do
      expect(page).to have_css(".comment", count: 20)

      click_button "Load more comments"

      expect(page).to have_css(".comment", minimum: 25)

      # Find reply buttons and click on one of the newly loaded comments
      all_comments = page.all(".comment")
      reply_button = all_comments[20].find(".comment__actions button")
      reply_button.click

      expect(page).to have_css(".add-comment:not(.hidden) textarea")

      textarea = page.all(".add-comment:not(.hidden) textarea").last
      textarea.native.send_keys("This is my reply")

      expect(page).to have_button("Publish reply", disabled: false)

      click_button "Publish reply"

      expect(page).to have_text("This is my reply")
    end
  end

  context "when the locale is different than English" do
    before do
      visit resource_path

      within_language_menu do
        click_on "Castellano"
      end
    end

    it "shows the replies button in the correct locale" do
      expect(page).to have_text("3 respuestas")
    end

    it "loads the replies when clicking the button in the correct locale", :slow do
      click_button "3 respuestas"

      expect(page).to have_css(".comment-thread .comment", count: 4)
    end
  end
end
