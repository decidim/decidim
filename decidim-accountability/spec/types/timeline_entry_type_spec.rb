# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Accountability
    describe TimelineEntryType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:timeline_entry) }

      include_examples "traceable interface"
      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "entryDate" do
        let(:query) { "{ entryDate }" }

        it "returns the entryDate" do
          expect(response["entryDate"]).to eq(model.entry_date.to_date.iso8601)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale:"en")}}' }

        it "returns the title field" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale:"en")}}' }

        it "returns the description field" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "result" do
        let(:query) { "{ result { id } }" }

        it "returns the result" do
          expect(response["result"]["id"]).to eq(model.result.id.to_s)
        end
      end
    end
  end
end
