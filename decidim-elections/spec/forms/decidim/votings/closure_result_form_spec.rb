# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::ClosureResultForm do
  subject { described_class.from_params(attributes).with_context(polling_officer:) }

  let(:voting) { create(:voting) }
  let(:component) { create(:elections_component, participatory_space: voting) }
  let(:election) { create(:election, questions:, component:) }
  let!(:questions) { create_list(:question, 3, :complete) }
  let(:polling_station) { create(:polling_station, voting: component.participatory_space) }
  let(:polling_officer) { create(:polling_officer, voting: component.participatory_space) }

  let(:attributes) do
    {
      election_id: election&.id,
      polling_station_id: polling_station&.id,
      answer_results:,
      question_results:
    }
  end

  let(:answer_results) do
    questions.flat_map do |question|
      question.answers.map do |answer|
        {
          id: answer.id,
          question_id: question.id,
          value: Faker::Number.number(digits: 1)
        }
      end
    end
  end

  let(:question_results) do
    questions.map do |question|
      {
        id: question.id,
        value: Faker::Number.number(digits: 1)
      }
    end
  end

  it { is_expected.to be_valid }

  describe "when polling_station is missing" do
    let(:polling_station) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when election is missing" do
    let(:election) { nil }

    it { is_expected.to be_invalid }
  end
end
