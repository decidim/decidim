# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::AnswerResultForm do
  subject { described_class.from_params(attributes) }

  let(:answer) { create(:election_answer, question: question) }
  let(:question) { create(:question) }
  let(:answer_id) { answer.id }
  let(:question_id) { question.id }
  let(:value) { 123 }

  let(:attributes) do
    {
      id: answer_id,
      question_id: question_id,
      value: value
    }
  end

  it { is_expected.to be_valid }

  describe "when answer_id is missing" do
    let(:answer_id) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when question_id is missing" do
    let(:question_id) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when value is missing" do
    let(:value) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when value is not a number" do
    let(:value) { "abcde" }

    it { is_expected.to be_invalid }
  end
end
