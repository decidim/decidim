# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings
  describe CreatePollingStationResults do
    subject { described_class.new(form, closure) }

    let(:voting) { create(:voting) }
    let(:component) { create(:elections_component, participatory_space: voting) }
    let(:election) { create(:election, questions: questions, component: component) }
    let(:closure) { create(:ps_closure, election: election, polling_station: polling_station, polling_officer: polling_officer) }
    let!(:questions) { create_list(:question, 3, :complete) }
    let(:polling_station) { create(:polling_station, voting: component.participatory_space) }
    let(:polling_officer) { create(:polling_officer, voting: component.participatory_space) }
    let(:context) { { polling_officer: polling_officer } }

    let(:params) do
      {
        polling_station_id: polling_station_id,
        election_id: election_id,
        ballot_results: ballot_results,
        answer_results: answer_results,
        question_results: question_results
      }
    end

    let(:polling_station_id) { polling_station.id }
    let(:election_id) { election.id }
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
    let(:ballot_results) do
      {
        valid_ballots_count: Faker::Number.number(digits: 1),
        blank_ballots_count: Faker::Number.number(digits: 1),
        null_ballots_count: Faker::Number.number(digits: 1)
      }
    end

    let(:form) { ClosureResultForm.from_params(params).with_context(context) }

    context "when the form is not valid" do
      let(:polling_station_id) { nil }

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end
    end

    context "when results are created" do
      it "broadcasts ok" do
        expect(subject.call).to broadcast(:ok)
      end

      it "changes to certificate phase" do
        subject.call

        expect(closure.certificate_phase?).to be true
      end
    end
  end
end
