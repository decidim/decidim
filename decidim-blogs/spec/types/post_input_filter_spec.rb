# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"
require "decidim/core/test/shared_examples/input_filter_examples"

module Decidim
  module Blogs
    describe PostInputFilter, type: :graphql do
      include_context "with a graphql class type"
      let(:type_class) { Decidim::Blogs::BlogsType }

      let(:model) { create(:post_component) }
      let!(:models) { create_list(:post, 3, component: model) }

      context "when filtered by created_at" do
        include_examples "connection has before/since input filter", "posts", "created"
      end

      context "when filtered by updated_at" do
        include_examples "connection has before/since input filter", "posts", "updated"
      end
    end
  end
end
