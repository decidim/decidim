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
      expect(subject).to have_content("Last published")
      expect(subject).to have_content("Blog post title")
      expect(subject).to have_css(".card__grid", count: 1)
    end
  end

  context "with 4 posts" do
    let!(:posts) { create_list(:post, 3, component:, created_at: 1.day.ago) }
    let!(:post) { create(:post, title: { en: "Blog post title" }, component:, created_at: 1.year.ago) }

    it "renders 3 posts" do
      expect(subject).to have_content("Last published")
      expect(subject).not_to have_content("Blog post title")
      expect(subject).to have_css(".card__grid", count: 3)
    end
  end

  context "with no posts" do
    it "renders nothing" do
      expect(subject).not_to have_content("Last published")
      expect(subject).not_to have_css(".card__grid", count: 1)
    end
  end
end
