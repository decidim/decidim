# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings
  describe CreatePollingStationResults do
    subject { described_class.new(form, closure) }

    let(:voting) { create(:voting) }
    let(:component) { create(:elections_component, participatory_space: voting) }
    let(:election) { create(:election, questions:, component:) }
    let(:closure) { create(:ps_closure, election:, polling_station:, polling_officer:) }
    let!(:questions) { create_list(:question, 3, :complete) }
    let(:polling_station) { create(:polling_station, voting: component.participatory_space) }
    let(:polling_officer) { create(:polling_officer, voting: component.participatory_space) }
    let(:context) { { polling_officer: } }

    let(:params) do
      {
        polling_station_id:,
        election_id:,
        ballot_results:,
        answer_results:,
        question_results:
      }
    end

    let(:polling_station_id) { polling_station.id }
    let(:election_id) { election.id }
    let(:answer_results) do
      questions.flat_map do |question|
        question.answers.to_h do |answer|
          [answer.id.to_s,
           {
             id: answer.id,
             question_id: question.id,
             value: 2
           }]
        end
      end.inject(:merge)
    end
    let(:question_results) do
      questions.to_h do |question|
        [question.id.to_s, {
          id: question.id,
          value: 2
        }]
      end
    end
    let(:ballot_results) do
      {
        valid_ballots_count: 10,
        blank_ballots_count: 5,
        null_ballots_count: 5,
        total_ballots_count: 20
      }
    end

    let(:form) { ClosureResultForm.from_params(params).with_context(context) }

    context "when invalid recounts" do
      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end

      it "return errors" do
        subject.call
        expect(form.errors.messages[:base].join).to include("Expected total of blank votes is 5 but the sum of the blank questions is 6")
        expect(form.errors.messages[:base].join).to include("Expected total of valid votes is 10 but the sum of the valid questions is 18.")
      end
    end

    context "when valid recounts" do
      let(:ballot_results) do
        {
          valid_ballots_count: 18,
          blank_ballots_count: 6,
          null_ballots_count: 5,
          total_ballots_count: 29
        }
      end

      it "broadcasts ok" do
        expect(subject.call).to broadcast(:ok)
      end

      it "changes to certificate phase" do
        subject.call
        expect(closure.certificate_phase?).to be true
      end

      context "when no polling station" do
        let(:polling_station_id) { nil }

        it "broadcasts invalid" do
          expect(subject.call).to broadcast(:invalid)
        end
      end
    end
  end
end
