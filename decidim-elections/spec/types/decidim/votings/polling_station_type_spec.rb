# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Votings
    describe PollingStationType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:polling_station) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { "{ title { translation(locale: \"ca\") } }" }

        it "returns the polling station's title" do
          expect(response["title"]["translation"]).to eq(model.title["ca"])
        end
      end

      describe "address" do
        let(:query) { "{ address }" }

        it "returns the polling station's address" do
          expect(response["address"]).to eq(model.address)
        end
      end

      describe "coordinates" do
        let(:query) { "{ coordinates { latitude longitude } }" }

        it "returns the polling station's address" do
          expect(response["coordinates"]).to include(
            "latitude" => model.latitude,
            "longitude" => model.longitude
          )
        end
      end

      describe "location" do
        let(:query) { "{ location { translation(locale: \"ca\") } }" }

        it "returns the polling station's location" do
          expect(response["location"]["translation"]).to eq(model.location["ca"])
        end
      end

      describe "locationHints" do
        let(:query) { "{ locationHints { translation(locale: \"ca\") } }" }

        it "returns the polling station's location_hints" do
          expect(response["locationHints"]["translation"]).to eq(model.location_hints["ca"])
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the polling station was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the polling station was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "voting" do
        let(:query) { "{ voting { id } }" }

        it "returns the voting space for this polling station" do
          expect(response["voting"]["id"]).to eq(model.voting.id.to_s)
        end
      end
    end
  end
end
