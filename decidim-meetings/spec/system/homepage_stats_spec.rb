# frozen_string_literal: true

require "spec_helper"

describe "Homepage", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:meetings) { create_list(:meeting, 3, :published, component:, author: component.organization) }
  let!(:moderation) { create :moderation, reportable: meetings.first, hidden_at: 1.day.ago }

  let(:day) { Time.zone.yesterday }
  let(:author) { create(:user, organization: component.organization) }
  let!(:comments) { create_list(:comment, 5, created_at: day, author:, commentable: meetings.last) }
  let!(:comment_moderation) { create :moderation, reportable: comments.last, hidden_at: 1.day.ago }

  before do
    create :content_block, organization: organization, scope_name: :homepage, manifest_name: :stats
    visit decidim.root_path
  end

  it "display unhidden meeting count" do
    within(".meetings_count") do
      expect(page).to have_content(2)
    end
  end

  it "display unhidden comments count" do
    within(".comments_count") do
      expect(page).to have_content(4)
    end
  end
end
