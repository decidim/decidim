# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::QuestionResultForm do
  subject { described_class.from_params(attributes).with_context(closure:) }

  let(:closure) { create(:ps_closure) }
  let(:question) { create(:question, election: closure.election, min_selections:, max_selections:) }
  let!(:result) { create(:election_result, :blank_ballots, election: closure.election, closurable: closure, question:, value: blank_total) }
  let(:question_id) { question.id }
  let(:value) { 123 }
  let(:max_selections) { 3 }
  let(:min_selections) { 0 }
  let(:blank_total) { 124 }

  let(:attributes) do
    {
      id: question_id,
      value:
    }
  end

  it { is_expected.to be_valid }

  context "when question_id is missing" do
    let(:question_id) { nil }

    it { is_expected.to be_invalid }
  end

  context "when value is missing" do
    let(:value) { nil }

    it { is_expected.to be_invalid }
  end

  context "when value not a number" do
    let(:value) { "abcde" }

    # The value is cast to the correct type so "abcde" becomes 0 which is valid.
    it { is_expected.to be_valid }
  end

  context "when value is greater than the number of blank ballots" do
    let(:blank_total) { 100 }

    it { is_expected.to be_invalid }
  end
end
