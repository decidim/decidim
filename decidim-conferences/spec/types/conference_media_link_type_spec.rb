# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Conferences
    describe ConferenceMediaLinkType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:media_link) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns the title field" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "link" do
        let(:query) { "{ link }" }

        it "returns the conference media link' link" do
          expect(response["link"]).to eq(model.link)
        end
      end

      describe "date" do
        let(:query) { "{ date }" }

        it "returns when the conference media link date field" do
          expect(response["date"]).to eq(model.date.to_date.iso8601)
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the conference media link' weight" do
          expect(response["weight"]).to eq(model.weight)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the conference media link was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the conference media link was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end
    end
  end
end
