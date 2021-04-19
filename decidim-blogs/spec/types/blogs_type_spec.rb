# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Blogs
    describe BlogsType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:post_component) }

      it_behaves_like "a component query type"

      describe "posts" do
        let!(:component_posts) { create_list(:post, 2, component: model) }
        let!(:other_posts) { create_list(:post, 2) }

        let(:query) { "{ posts { edges { node { id } } } }" }

        it "returns the published posts" do
          ids = response["posts"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*component_posts.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_posts.map(&:id).map(&:to_s))
        end
      end

      describe "post" do
        let(:query) { "query Post($id: ID!){ post(id: $id) { id } }" }
        let(:variables) { { id: post.id.to_s } }

        context "when the post belongs to the component" do
          let!(:post) { create(:post, component: model) }

          it "finds the post" do
            expect(response["post"]["id"]).to eq(post.id.to_s)
          end
        end

        context "when the post doesn't belong to the component" do
          let!(:post) { create(:post, component: create(:post_component)) }

          it "returns null" do
            expect(response["post"]).to be_nil
          end
        end
      end
    end
  end
end
