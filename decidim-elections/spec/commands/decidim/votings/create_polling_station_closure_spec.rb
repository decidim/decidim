# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings
  describe CreatePollingStationClosure do
    subject { described_class.new(form) }

    let(:voting) { create(:voting) }
    let(:component) { create(:elections_component, participatory_space: voting) }
    let(:election) { create(:election, component:) }
    let(:polling_station) { create(:polling_station, voting:) }
    let(:polling_officer) { create(:polling_officer, voting:) }

    let(:params) do
      {
        polling_station_id: polling_station.id,
        election_id: election.id,
        election_votes_count: 100,
        total_ballots_count:,
        polling_officer_notes:
      }
    end

    let(:total_ballots_count) { 100 }
    let(:polling_officer_notes) { Faker::Lorem.sentence }

    let(:form) { EnvelopesResultForm.new(params).with_context(polling_officer:) }

    context "when the form is not valid" do
      let(:total_ballots_count) { 101 }
      let(:polling_officer_notes) { nil }

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end
    end

    context "when the closure is created" do
      it "broadcasts ok" do
        expect(subject.call).to broadcast(:ok)
      end

      it "changes to results phase" do
        subject.call

        expect(PollingStationClosure.last.results_phase?).to be true
      end
    end
  end
end
