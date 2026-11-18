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

      describe "votes" do
        let(:suggestion) { create(:collaborative_text_suggestion) }
        let(:user) { create(:user, :confirmed, organization: suggestion.organization) }

        it "validates the weight" do
          expect(build(:collaborative_text_suggestion_vote, suggestion:, weight: 0)).not_to be_valid
        end

        it "validates the uniqueness of the author" do
          create(:collaborative_text_suggestion_vote, suggestion:, author: user)

          expect(build(:collaborative_text_suggestion_vote, suggestion:, author: user)).not_to be_valid
        end

        it "does not allow votes from another organization" do
          author = create(:user, :confirmed)

          expect(build(:collaborative_text_suggestion_vote, suggestion:, author:)).not_to be_valid
        end

        it "tracks the votes of the user" do
          create(:collaborative_text_suggestion_vote, suggestion:, author: user, weight: 1)

          expect(suggestion).to be_up_voted_by(user)
          expect(suggestion).not_to be_down_voted_by(user)
        end
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
