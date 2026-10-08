# frozen_string_literal: true

require "spec_helper"

describe Decidim::Blogs::ContentBlocks::HighlightedPostsCell, type: :cell do
  subject { cell("decidim/blogs/content_blocks/highlighted_posts", content_block).call }

  controller Decidim::Blogs::PostsController

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component) { create(:component, participatory_space:, manifest_name: "blogs") }
  let(:manifest_name) { :highlighted_posts }
  let(:scope_name) { :participatory_process_homepage }
  let(:content_block) { create(:content_block, organization:, manifest_name:, scope_name:, scoped_resource_id: participatory_space.id) }

  context "with 1 post" do
    let!(:post) { create(:post, title: { en: "Blog post title" }, component:) }

    it "renders the post" do
      expect(subject).to have_text("Last published")
      expect(subject).to have_text("Blog post title")
      expect(subject).to have_css(".card__grid", count: 1)
    end
  end

  context "with 4 posts" do
    let!(:posts) { create_list(:post, 3, component:, published_at: 1.day.ago) }
    let!(:post) { create(:post, title: { en: "Blog post title" }, component:, published_at: 1.year.ago) }

    it "renders the 3 most recently published posts" do
      expect(subject).to have_text("Last published")
      expect(subject).to have_no_text("Blog post title")
      expect(subject).to have_css(".card__grid", count: 3)
    end
  end

  context "with posts published in a different order than they were created" do
    let!(:oldest_created_latest_published) do
      create(:post, title: { en: "Latest published post" }, component:, created_at: 2.days.ago, published_at: 1.hour.ago)
    end
    let!(:latest_created_oldest_published) do
      create(:post, title: { en: "First published post" }, component:, created_at: 1.hour.ago, published_at: 2.days.ago)
    end

    it "orders posts by publication time, most recent first" do
      expect(subject.text.index("Latest published post")).to be < subject.text.index("First published post")
    end
  end

  context "with no posts" do
    it "renders nothing" do
      expect(subject).to have_no_text("Last published")
      expect(subject).to have_no_css(".card__grid", count: 1)
    end
  end
end
