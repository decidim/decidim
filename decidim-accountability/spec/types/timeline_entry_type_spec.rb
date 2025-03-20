# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Accountability
    describe TimelineEntryType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:timeline_entry) }

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

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns the createdAt" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns the updatedAt" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
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
