# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe MultiVoteForm do
      subject { described_class.from_params(attributes).with_context(context) }

      let(:question) { create :question, :multiple }
      let(:response1) { create :response, question: }
      let(:response2) { create :response, question: }
      let(:response3) { create :response, question: }
      let(:response4) { create :response, question: }
      let(:responses) { [response1.id, response2.id] }
      let(:attributes) do
        {
          responses:
        }
      end
      let(:context) do
        {
          "current_question" => question
        }
      end

      it { is_expected.to be_valid }

      context "when responses is nil" do
        let(:responses) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when voting without responses" do
        let(:responses) { [] }

        it { is_expected.not_to be_valid }
      end

      context "when some response points to non existing question" do
        let(:responses) { [response1.id, 999_999_999] }

        it { is_expected.not_to be_valid }

        it "Returns a message error" do
          subject.validate
          expect(subject.errors[:responses]).to include("Response not found.")
        end
      end

      context "when there are to few responses" do
        let(:responses) { [response1.id] }

        it { is_expected.not_to be_valid }

        it "Returns a message error" do
          subject.validate
          expect(subject.errors[:responses]).to include("Number of votes is invalid")
        end
      end

      context "when there are to many responses" do
        let(:responses) { [response1.id, response2.id, response3.id, response4.id] }

        it { is_expected.not_to be_valid }

        it "Returns a message error" do
          subject.validate
          expect(subject.errors[:responses]).to include("Number of votes is invalid")
        end
      end
    end
  end
end
