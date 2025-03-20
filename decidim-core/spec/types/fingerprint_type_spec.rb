# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe FingerprintType do
      include_context "with a graphql class type"

      let(:model) do
        double(
          value: "some_value",
          source: { "test" => "test object" }
        )
      end

      describe "value" do
        let(:query) { "{ value }" }

        it "returns value as a string" do
          expect(response["value"]).to eq("some_value")
        end
      end

      describe "source" do
        let(:query) { "{ source }" }

        it "returns source as a string" do
          expect(response["source"]).to eq("{\"test\"=>\"test object\"}")
        end
      end
    end
  end
end
