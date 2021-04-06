# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::AnswerResultForm do
  subject { described_class.from_params(attributes) }

  let(:answer) { create(:election_answer) }
  let(:answer_id) { answer.id }
  let(:votes_count) { 123 }

  let(:attributes) do
    {
      id: answer_id,
      votes_count: votes_count
    }
  end

  it { is_expected.to be_valid }

  describe "when answer_id is missing" do
    let(:answer_id) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when votes_count is missing" do
    let(:votes_count) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when votes_count not a number" do
    let(:votes_count) { "abcde" }

    it { is_expected.to be_invalid }
  end
end
