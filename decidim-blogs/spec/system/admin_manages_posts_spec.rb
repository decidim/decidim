# frozen_string_literal: true

require "spec_helper"

describe "Admin manages posts", type: :system do
  let(:manifest_name) { "blogs" }
  let(:two_days_ago) { 2.days.ago.strftime("%d/%m/%Y %H:%M") }
  let(:two_days_from_now) { 2.days.from_now.strftime("%d/%m/%Y %H:%M") }
  let!(:post1) { create(:post, component: current_component, author:, title: { en: "Post title 1" }, created_at: two_days_ago, published_at: two_days_ago) }
  let!(:post2) { create(:post, component: current_component, title: { en: "Post title 2" }, published_at: two_days_from_now) }
  let(:author) { create(:user, organization:) }

  include_context "when managing a component as an admin"

  context "when author is the organization" do
    let(:author) { organization }

    it_behaves_like "manage posts"
  end

  context "when author is a user" do
    let(:author) { create(:user, organization:) }

    it_behaves_like "manage posts"
  end

  it "sets publish time correctly" do
    within "table" do
      within find("tr", text: translated(post1.title)) do
        expect(page).to have_content(two_days_ago)
      end
      within find("tr", text: translated(post2.title)) do
        expect(page).to have_content(two_days_from_now)
        expect(find("td:nth-child(4) svg")[:class]).to have_content("icon--clock icon")
      end
    end
  end
end
