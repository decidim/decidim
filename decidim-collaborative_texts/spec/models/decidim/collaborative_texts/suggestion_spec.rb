# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe Suggestion do
      subject { collaborative_text_suggestion }

      let(:document_version) { create(:collaborative_text_version) }
      let(:collaborative_text_suggestion) { build(:collaborative_text_suggestion, document_version:) }

      it { is_expected.to be_valid }

      it "has a document version" do
        expect(collaborative_text_suggestion.document_version).to be_a(Decidim::CollaborativeTexts::Version)
      end

      context "when suggestion is saved" do
        let(:another_document_version) { create(:collaborative_text_version, document: document_version.document) }
        let!(:another_collaborative_text_suggestion) { create(:collaborative_text_suggestion, document_version: another_document_version) }

        it "updates suggestions count" do
          expect(collaborative_text_suggestion.document.suggestions_count).to eq(1)
          expect(document_version.suggestions_count).to eq(0)
          collaborative_text_suggestion.save
          expect(document_version.suggestions_count).to eq(1)
          expect(collaborative_text_suggestion.document.suggestions_count).to eq(2)
        end
      end

      describe "#commentable?" do
        subject { collaborative_text_suggestion.commentable? }

        context "when the document is published" do
          let(:document) { create(:collaborative_text_document, :published) }
          let(:document_version) { create(:collaborative_text_version, document:) }

          it { is_expected.to be true }

          it "can have comments" do
            suggestion = create(:collaborative_text_suggestion, document_version:)

            expect { create(:comment, commentable: suggestion) }.to change { suggestion.reload.comments_count }.by(1)
          end
        end

        context "when the document is not published" do
          it { is_expected.to be false }
        end
      end
    end
  end
end
