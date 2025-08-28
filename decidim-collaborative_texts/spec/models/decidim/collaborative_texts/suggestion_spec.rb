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
    end
  end
end
