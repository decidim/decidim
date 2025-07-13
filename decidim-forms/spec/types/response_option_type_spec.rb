# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Forms
    describe ResponseOptionType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:response_option) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the question's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "body" do
        let(:query) { "{ body { translation(locale: \"ca\") } }" }

        it "returns the question's body" do
          expect(response["body"]["translation"]).to eq(model.body["ca"])
        end
      end

      describe "freeText" do
        let(:query) { "{ freeText }" }

        it "returns the question's freeText" do
          expect(response["freeText"]).to eq(model.free_text)
        end
      end
    end
  end
end
