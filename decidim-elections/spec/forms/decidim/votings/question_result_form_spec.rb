# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::QuestionResultForm do
  subject { described_class.from_params(attributes) }

  let(:question) { create(:question) }
  let(:question_id) { question.id }
  let(:votes_count) { 123 }

  let(:attributes) do
    {
      id: question_id,
      votes_count: votes_count
    }
  end

  it { is_expected.to be_valid }

  describe "when question_id is missing" do
    let(:question_id) { nil }

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
