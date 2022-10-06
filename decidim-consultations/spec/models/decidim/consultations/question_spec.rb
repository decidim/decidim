# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe Question do
      subject { question }

      let(:question) { build(:question) }
      let(:max_votes) { nil }

      it { is_expected.to be_valid }

      describe ".hashtag" do
        let(:question) { build :question, hashtag: "#hashtag", max_votes: }

        it "Do not includes the hash character" do
          expect(question.hashtag).to eq("hashtag")
        end
      end

      describe ".voted_by?" do
        let(:question) { create(:question) }
        let!(:vote) { create(:vote, question:) }

        it "returns true when the user has voted the question" do
          expect(question).to be_voted_by(vote.author)
        end

        it "returns false when the user has not voted the question" do
          expect(question).not_to be_voted_by(create(:user))
        end
      end

      describe ".multiple?" do
        let(:question) { create(:question) }

        context "when max_votes is not defined" do
          it "returns false" do
            expect(question.multiple?).to be(false)
          end
        end

        context "when max_votes is defined" do
          let(:max_votes) { 2 }

          it "returns true" do
            expect(question.multiple?).not_to be(true)
          end
        end
      end

      include_examples "publicable"
    end
  end
end
