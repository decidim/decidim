# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"
require "decidim/core/test/shared_examples/input_sort_examples"

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

      context "when sorting by endorsement_count" do
        let!(:most_endorsed) { create(:post, :with_endorsements, component: model) }

        include_examples "connection has endorsement_count sort", "posts"
      end
    end
  end
end
