# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/attachable_interface_examples"
require "decidim/core/test/shared_examples/authorable_interface_examples"

module Decidim
  module Blogs
    describe PostType, type: :graphql do
      include_context "with a graphql type"

      let(:model) { create(:post) }

      include_examples "attachable interface"
      include_examples "authorable interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "body" do
        let(:query) { '{ body { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["body"]["translation"]).to eq(model.body["en"])
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the page was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the page was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "author" do
        let(:query) { "{ author { name }}" }

        it "returns the author of the post" do
          expect(response["author"]["name"]).to eq(model.author.name)
        end
      end
    end
  end
end
