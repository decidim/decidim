# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::ClosureResultForm do
  subject { described_class.from_params(attributes).with_context(polling_officer:) }

  let(:voting) { create(:voting) }
  let(:component) { create(:elections_component, participatory_space: voting) }
  let(:election) { create(:election, questions:, component:) }
  let!(:questions) { create_list(:question, 3, :complete, :nota) }
  let(:polling_station) { create(:polling_station, voting: component.participatory_space) }
  let(:polling_officer) { create(:polling_officer, voting: component.participatory_space) }
  let(:total_ballots_count) { valid_ballots_count.to_i + null_ballots_count.to_i + blank_ballots_count.to_i }
  let(:valid_ballots_count) { Faker::Number.number(digits: 1) }
  let(:blank_ballots_count) { Faker::Number.number(digits: 1) }
  let(:null_ballots_count) { Faker::Number.number(digits: 1) }

  let(:ballot_results) do
    {
      total_ballots_count:,
      valid_ballots_count:,
      blank_ballots_count:,
      null_ballots_count:
    }
  end
  let(:attributes) do
    {
      election_id: election&.id,
      polling_station_id: polling_station&.id,
      answer_results:,
      question_results:,
      ballot_results:
    }
  end

  let(:answer_results) do
    questions.flat_map do |question|
      question.answers.map do |answer|
        [question.id.to_s, {
          id: answer.id,
          question_id: question.id,
          value: Faker::Number.number(digits: 1)
        }]
      end
    end.to_h
  end

  let(:question_results) do
    questions.to_h do |question|
      [question.id.to_s, {
        id: question.id,
        value: Faker::Number.number(digits: 1)
      }]
    end
  end

  it { is_expected.to be_valid }

  context "when polling_station is missing" do
    let(:polling_station) { nil }

    it { is_expected.to be_invalid }
  end

  context "when election is missing" do
    let(:election) { nil }

    it { is_expected.to be_invalid }
  end

  context "when total votes does not match vote breakdown" do
    let(:total_ballots_count) { 0 }

    it { is_expected.to be_invalid }
  end

  context "when number of blank votes exceeds the total blank ballots" do
    it { is_expected.to be_invalid }
  end

  context "when number of answers exceeds the total valid ballots" do
    it { is_expected.to be_invalid }
  end
end
