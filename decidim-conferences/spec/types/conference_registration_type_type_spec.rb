# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Conferences
    describe ConferenceRegistrationTypeType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:registration_type) }

      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns the title field" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns when the conference was published" do
          expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the weight field" do
          expect(response["weight"]).to eq(model.weight)
        end
      end

      describe "price" do
        let(:query) { "{ price }" }

        it "returns the price field" do
          expect(response["price"]).to eq(model.price)
        end
      end
    end
  end
end
