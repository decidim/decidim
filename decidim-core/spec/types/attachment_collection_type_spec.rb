# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe AttachmentCollectionType do
      include_context "with a graphql class type"

      let(:model) { create(:attachment_collection) }


      describe "name" do
        let(:query) { '{ name { translation(locale: "en")}}' }

        it "returns the attachment's collection name" do
          expect(response["name"]["translation"]).to eq(translated(model.name))
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns the attachment's collection description" do
          expect(response["description"]["translation"]).to eq(translated(model.description))
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the attachment's collection weight" do
          expect(response).to eq("weight" => model.weight.to_s)
        end
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the attachment's id" do
          expect(response).to eq("id" => model.id.to_s)
        end
      end

    end
  end
end
