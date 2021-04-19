# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe CoordinatesType do
      include_context "with a graphql class type"

      let(:latitude) { 41.387015 }
      let(:longitude) { 2.170047 }

      let(:model) do
        [latitude, longitude]
      end

      describe "latitude" do
        let(:query) { "{ latitude }" }

        it "returns the coordinate's longitude" do
          expect(response).to eq("latitude" => latitude)
        end
      end

      describe "longitude" do
        let(:query) { "{ longitude }" }

        it "returns the coordinate's longitude" do
          expect(response).to eq("longitude" => longitude)
        end
      end
    end
  end
end
