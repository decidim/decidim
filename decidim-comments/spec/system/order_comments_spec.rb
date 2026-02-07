# frozen_string_literal: true

require "spec_helper"

describe "Order comments" do
  let!(:organization) { create(:organization) }
  let!(:component) { create(:component, manifest_name: :dummy, organization:) }
  let!(:commentable) { create(:dummy_resource, component:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:recent_comment) { create(:comment, body: "Recent Comment", commentable:, created_at: 1.day.ago) }
  let!(:oldest_comment) { create(:comment, body: "Oldest Comment", commentable:, created_at: 5.days.ago) }
  let!(:comment_vote) { create(:comment_vote, comment: best_rated_comment, author: user, weight: 1, created_at: 2.days.ago) }
  let!(:best_rated_comment) { create(:comment, body: "Best rated Comment", commentable:, created_at: 2.days.ago) }

  let!(:most_discussed_comment) { create(:comment, body: "Most discussed Comment", commentable:, created_at: 2.days.ago) }
  let!(:reply) { create(:comment, commentable: most_discussed_comment, root_commentable: commentable) }

  let(:resource_path) { resource_locator(commentable).path }

  before do
    switch_to_host(organization.host)
    visit resource_path
  end

  after do
    expect_no_js_errors
  end

  context "when accessing a resource page" do
    it "\"Older\" value is the default sorting criteria" do
      within ".comments__header" do
        expect(page).to have_css("div.comment-order-by")
        expect(page).to have_select("order", selected: "Older")
      end

      within(".comment-threads") do
        first_comment = all("div[id^='comment_']").first
        expect(first_comment[:id]).to eq("comment_#{oldest_comment.id}")
      end
    end

    it "user selects \"Best rated\" as sorting criteria", :js, :slow do
      within ".comment-order-by" do
        select "Best rated", from: "order"
      end

      within(".comment-threads", wait: 5) do
        expect(page).to have_css("div:first-child#comment_#{best_rated_comment.id}", wait: 5)
      end

      expect(page).to have_select("order", selected: "Best rated", wait: 5)
    end

    it "user selects \"Most discussed\" as sorting criteria", :js, :slow do
      within ".comment-order-by" do
        select "Most discussed", from: "order"
      end

      within(".comment-threads", wait: 5) do
        expect(page).to have_css("div:first-child#comment_#{most_discussed_comment.id}", wait: 5)
      end

      expect(page).to have_select("order", selected: "Most discussed", wait: 5)
    end

    it "user selects \"Recent\" as sorting criteria", :js, :slow do
      within ".comment-order-by" do
        select "Recent", from: "order"
      end

      within(".comment-threads", wait: 5) do
        expect(page).to have_css("div:first-child#comment_#{recent_comment.id}", wait: 5)
      end

      expect(page).to have_select("order", selected: "Recent", wait: 5)
    end
  end
end
