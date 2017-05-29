# frozen_string_literal: true

require "spec_helper"

describe "Comment notifications", type: :feature do
  let!(:organization) { create(:organization) }
  let!(:feature) { create(:feature, manifest_name: :dummy, organization: organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:commentable) { create(:dummy_resource, feature: feature) }
  let!(:comments) do
    Array.new(3) do
      create(:comment, commentable: commentable)
    end
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "commentable author receives an email with a link to the comment", perform_enqueued: true do
    visit decidim_dummy.dummy_resource_path(commentable, feature_id: commentable.feature, participatory_process_id: commentable.feature.participatory_process)
    expect(page).to have_selector(".add-comment form")

    within ".add-comment form" do
      fill_in "add-comment-#{commentable.class.name}-#{commentable.id}", with: "This is a new comment"
      click_button "Send"
    end

    within "#comments" do
      expect(page).to have_content user.name
      expect(page).to have_content "This is a new comment"
    end

    wait_for_email subject: "a new comment"

    login_as commentable.author, scope: :user

    visit last_email_first_link

    within "#comments" do
      expect(page).to have_content user.name
      expect(page).to have_content "This is a new comment"
    end
  end
end
