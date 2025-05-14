# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module CollaborativeTexts
    describe SuggestionType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:collaborative_text_suggestion) }

      include_examples "authorable interface"
      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id versionsCount }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
          expect(response).to include("versionsCount" => model.versions_count)
        end
      end

      describe "changeset" do
        let(:query) { "{ changeset }" }

        it "returns all the required fields" do
          expect(response).to include("changeset" => model.changeset)
        end
      end

      describe "status" do
        let(:query) { "{ status }" }

        it "returns all the required fields" do
          expect(response).to include("status" => model.status)
        end
      end

      describe "documentVersion" do
        let(:query) { "{ documentVersion { id } }" }

        it "returns all the required fields" do
          expect(response["documentVersion"]).to include("id" => model.document_version.id.to_s)
        end
      end
    end
  end
end
