# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/attachable_interface_examples"
require "decidim/core/test/shared_examples/authorable_interface_examples"
require "decidim/core/test/shared_examples/traceable_interface_examples"
require "decidim/core/test/shared_examples/timestamps_interface_examples"
require "decidim/core/test/shared_examples/endorsable_interface_examples"

module Decidim
  module Blogs
    describe PostType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:post) }

      include_examples "attachable interface"
      include_examples "authorable interface"
      include_examples "traceable interface"
      include_examples "timestamps interface"
      include_examples "endorsable interface"

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
    end
  end
end
