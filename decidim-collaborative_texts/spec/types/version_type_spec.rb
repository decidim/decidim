# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module CollaborativeTexts
    describe VersionType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:collaborative_text_version) }
      let!(:suggestions) { create_list(:collaborative_text_suggestion, 2, document_version: model) }

      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id versionsCount }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
          expect(response).to include("versionsCount" => model.versions_count)
        end
      end

      describe "body" do
        let(:query) { "{ body }" }

        it "returns all the required fields" do
          expect(response).to include("body" => model.body)
        end
      end

      describe "draft" do
        let(:query) { "{ draft }" }

        it "returns all the required fields" do
          expect(response).to include("draft" => model.draft)
        end
      end

      describe "document" do
        let(:query) { "{ document { id } }" }

        it "returns all the required fields" do
          expect(response["document"]).to include("id" => model.document.id.to_s)
        end
      end

      describe "suggestionsCount" do
        let(:query) { "{ suggestionsCount }" }

        it "returns all the required fields" do
          expect(response).to include("suggestionsCount" => model.suggestions_count)
        end
      end

      describe "suggestions" do
        let(:query) { "{ suggestions { id } }" }

        it "returns all the required fields" do
          expect(response["suggestions"].count).to eq(suggestions.count)
          expect(response["suggestions"].map { |s| s["id"] }).to match_array(suggestions.map(&:id).map(&:to_s))
        end
      end
    end
  end
end
