# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::BallotStyle do
  let(:election) { create(:election, :complete) }

  describe "#questions_for" do
    subject { ballot_style.questions_for(election) }

    context "when the ballot style has questions from another election" do
      # Adds questions from another election to the ballot style
      let(:other_election) { create(:election, :complete) }
      let(:ballot_style_questions_from_other_election) do
        other_election.questions.first(2).each do |question|
          create(:ballot_style_question, question:, ballot_style:)
        end
      end

      context "when the ballot style has questions from this election" do
        let(:ballot_style) { create(:ballot_style, :with_ballot_style_questions, election:) }

        it "returns the questions for the specified election" do
          expect(subject).to match_array(election.questions.first(2))
        end
      end

      context "when the ballot style has questions from another election" do
        let(:ballot_style) { create(:ballot_style) }

        it "returns the questions for the specified election" do
          expect(subject).to be_empty
        end
      end
    end

    context "when the ballot style DOES NOT HAVE questions from another election" do
      context "when the ballot style has questions from this election" do
        let(:ballot_style) { create(:ballot_style, :with_ballot_style_questions, election:) }

        it "returns the questions for the specified election" do
          expect(subject).to match_array(election.questions.first(2))
        end
      end

      context "when the ballot style has questions from another election" do
        let(:ballot_style) { create(:ballot_style) }

        it "returns the questions for the specified election" do
          expect(subject).to be_empty
        end
      end
    end
  end
end
