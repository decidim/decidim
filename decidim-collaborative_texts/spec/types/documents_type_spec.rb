# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module CollaborativeTexts
    describe DocumentsType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:collaborative_text_component) }

      it_behaves_like "a component query type"

      describe "collaborativeTexts" do
        let!(:component_documents) { create_list(:collaborative_text_document, 2, :published, component: model) }
        let!(:other_documents) { create_list(:collaborative_text_document, 2, :published) }

        let(:query) { "{ collaborativeTexts { edges { node { id } } } }" }

        it "returns the published documents" do
          ids = response["collaborativeTexts"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*component_documents.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_documents.map(&:id).map(&:to_s))
        end
      end

      describe "collaborativeText" do
        let(:query) { "query CollaborativeText($id: ID!){ collaborativeText(id: $id) { id } }" }
        let(:variables) { { id: document.id.to_s } }

        context "when the document belongs to the component" do
          let!(:document) { create(:collaborative_text_document, :published, component: model) }

          it "finds the document" do
            expect(response["collaborativeText"]["id"]).to eq(document.id.to_s)
          end
        end

        context "when the document does not belong to the component" do
          let!(:document) { create(:collaborative_text_document, :published, component: create(:collaborative_text_component)) }

          it "returns null" do
            expect(response["collaborativeText"]).to be_nil
          end
        end
      end
    end
  end
end
