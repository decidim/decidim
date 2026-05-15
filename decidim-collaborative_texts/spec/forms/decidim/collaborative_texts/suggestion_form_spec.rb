# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe SuggestionForm do
      subject(:form) { described_class.from_params(attributes).with_context(context) }

      let(:context) { { current_user: user } }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:organization) { create(:organization) }
      let(:document) { create(:collaborative_text_document, component:, document_versions: [document_version]) }
      let(:document_version) { build(:collaborative_text_version) }
      let(:component) { create(:collaborative_text_component, organization:) }
      let(:attributes) do
        {
          changeset: {
            original: ["original text"],
            replace: ["replacement text"],
            firstNode: 1,
            lastNode: 2
          },
          document_id: document.id
        }
      end

      describe "attributes" do
        it "has a changeset" do
          expect(form.changeset).to eq(
            {
              "original" => ["original text"],
              "replace" => ["replacement text"],
              "firstNode" => 1,
              "lastNode" => 2
            }
          )
        end

        it "has a status" do
          expect(form.status).to eq("pending")
        end

        it "has a document_id" do
          expect(form.document_id).to eq(document.id)
        end

        it "has an author" do
          expect(form.author).to eq(user)
        end

        it "has a document" do
          expect(form.document).to eq(document)
        end

        it "has a document_version" do
          expect(form.document_version).to eq(document.current_version)
        end
      end

      describe "validations" do
        context "when changeset is blank" do
          let(:attributes) { { changeset: {}, document_id: document.id } }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:base]).to include("Changeset cannot be blank.")
          end
        end

        context "when firstNode is zero" do
          let(:attributes) { { changeset: { firstNode: 0, lastNode: 2 }, document_id: document.id } }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:base]).to include("Invalid selected nodes.")
          end
        end

        context "when firstNode is not a number" do
          let(:attributes) { { changeset: { firstNode: "not a number", lastNode: 2 }, document_id: document.id } }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:base]).to include("Invalid selected nodes.")
          end
        end

        context "when lastNode is zero" do
          let(:attributes) { { changeset: { firstNode: 1, lastNode: 0 }, document_id: document.id } }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:base]).to include("Invalid selected nodes.")
          end
        end

        context "when all attributes are valid" do
          it "is valid" do
            expect(form).to be_valid
          end
        end
      end
    end
  end
end
