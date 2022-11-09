# frozen_string_literal: true

require "spec_helper"

describe Decidim::Blogs::Engine do
  describe "decidim_blogs.authorization_transfer" do
    include_context "authorization transfer"

    let(:component) { create(:post_component, organization:) }
    let(:original_records) do
      { posts: create_list(:post, 3, component:, author: original_user) }
    end
    let(:transferred_posts) { Decidim::Blogs::Post.where(author: target_user).order(:id) }

    it "handles authorization transfer correctly" do
      expect(transferred_posts.count).to eq(3)
      expect(transfer.records.count).to eq(3)
      expect(transferred_resources).to eq(transferred_posts)
    end
  end
end
