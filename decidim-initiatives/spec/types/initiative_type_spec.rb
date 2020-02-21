# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Initiatives
    describe InitiativeType, type: :graphql do
      include_context "with a graphql type"

      let(:model) { create(:initiative) }

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

      describe "slug" do
        let(:query) { "{ slug }" }

        it "returns the initiative' slug" do
          expect(response["slug"]).to eq(model.slug)
        end
      end

      describe "hashtag" do
        let(:query) { "{ hashtag }" }

        it "returns the initiative' hashtag" do
          expect(response["hashtag"]).to eq(model.hashtag)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the initiative was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the initiative was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns when the initiative was published" do
          expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "signatureStartDate" do
        let(:query) { "{ signatureStartDate }" }

        it "returns the signature start date of the initiative " do
          expect(response["signatureStartDate"]).to eq(model.signature_start_date.to_date.iso8601)
        end
      end

      describe "signatureEndDate" do
        let(:query) { "{ signatureEndDate }" }

        it "returns when the initiative signature date ends" do
          expect(response["signatureEndDate"]).to eq(model.signature_end_date.to_date.iso8601)
        end
      end

      describe "reference" do
        let(:query) { "{ reference }" }

        it "returns the initiative' reference" do
          expect(response["reference"]).to eq(model.reference)
        end
      end

      describe "scope" do
        let(:query) { "{ scope { id } }" }

        it "has a scope" do
          expect(response).to include("scope" => { "id" => model.scope.id.to_s })
        end
      end
    end
  end
end
