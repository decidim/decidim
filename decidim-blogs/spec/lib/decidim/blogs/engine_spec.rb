# frozen_string_literal: true

require "spec_helper"

describe Decidim::Blogs::Engine do
  describe "decidim_blogs.authorization_transfer" do
    include_context "authorization transfer"

    let(:component) { create(:post_component, organization: organization) }
    let(:original_records) do
      { posts: create_list(:post, 3, component: component, author: original_user) }
    end
    let(:transferred_posts) { Decidim::Blogs::Post.where(author: target_user) }

    it "handles authorization transfer correctly" do
      expect(transferred_posts.count).to eq(3)
    end
  end
end
