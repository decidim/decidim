# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::EnvelopesResultForm do
  subject { described_class.from_params(attributes).with_context(polling_officer:) }

  let(:voting) { create(:voting) }
  let(:component) { create(:elections_component, participatory_space: voting) }
  let(:election) { create(:election, questions:, component:) }
  let!(:questions) { create_list(:question, 3, :complete) }
  let(:polling_station) { create(:polling_station, voting: component.participatory_space) }
  let(:polling_officer) { create(:polling_officer, voting: component.participatory_space) }

  let(:polling_station_id) { polling_station&.id }
  let(:election_id) { election&.id }
  let(:total_ballots_count) { Faker::Number.number(digits: 1) }
  let(:polling_officer_notes) { nil }
  let(:election_votes_count) { total_ballots_count }

  let(:attributes) do
    {
      polling_station_id:,
      election_id:,
      total_ballots_count:,
      polling_officer_notes:,
      election_votes_count:
    }
  end

  it { is_expected.to be_valid }

  describe "when polling_station_id is missing" do
    let(:polling_station_id) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when election_id is missing" do
    let(:election_id) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when total_ballots_count is missing" do
    let(:total_ballots_count) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when total_ballots_count differ from election_votes_count" do
    let(:election_votes_count) { 2 }
    let(:total_ballots_count) { 1 }

    context "and polling_officer_notes is missing" do
      it { is_expected.to be_invalid }
    end

    context "and polling_officer_notes is present" do
      let(:polling_officer_notes) { Faker::Lorem.sentence }

      it { is_expected.to be_valid }
    end
  end
end
