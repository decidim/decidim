# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Blogs
    describe PostInputSort, type: :graphql do
      include_context "with a graphql class type"

      let(:type_class) { Decidim::Blogs::BlogsType }

      let(:model) { create(:post_component) }
      let!(:models) { create_list(:post, 3, component: model) }

      context "when sorting by posts id" do
        include_examples "connection has input sort", "posts", "id"
      end

      context "when sorting by created_at" do
        include_examples "connection has input sort", "posts", "createdAt"
      end

      context "when sorting by updated_at" do
        include_examples "connection has input sort", "posts", "updatedAt"
      end

      context "when sorting by like_count" do
        let!(:most_liked) { create(:post, :with_likes, component: model) }

        include_examples "connection has like_count sort", "posts"
      end
    end
  end
end
