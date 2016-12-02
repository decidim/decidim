# frozen_string_literal: true
require "spec_helper"

describe "Comments", type: :feature do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:participatory_process) { create(:participatory_process, organization: organization) }
  let!(:comments) {
    3.times.map do
      create(:comment, commentable: participatory_process)
    end
  }

  before do
    switch_to_host(organization.host)
  end

  it "user should see a list of comments" do
    visit decidim.participatory_process_path(participatory_process)

    expect(page).to have_selector("#comments")
    expect(page).to have_selector("article.comment", count: comments.length)

    within "#comments" do
      comments.each do |comment|
        expect(page).to have_content comment.author.name
        expect(page).to have_content comment.body
      end
    end
  end

  context "when not authenticated" do
    it "user should not see the form to add comments" do
      visit decidim.participatory_process_path(participatory_process)
      expect(page).to_not have_selector(".add-comment form")
    end
  end

  context "when authenticated" do
    before do
      login_as user, scope: :user
    end

    it "user should not see the form to add comments" do
      visit decidim.participatory_process_path(participatory_process)
      expect(page).to have_selector(".add-comment form")
    end

    it "user can add a new comment" do
      visit decidim.participatory_process_path(participatory_process)
      expect(page).to have_selector(".add-comment form")

      within ".add-comment form" do
        fill_in 'add-comment', with: "This is a new comment"
        click_button "Send"
      end

      within "#comments" do
        comments.each do |comment|
          expect(page).to have_content user.name
          expect(page).to have_content "This is a new comment"
        end
      end
    end
  end
end