# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::PollingStationClosure, type: :model do
  subject(:closure) { build(:ps_closure) }

  it { is_expected.to be_valid }

  it "has an associated election" do
    expect(closure.election).to be_a(Decidim::Elections::Election)
  end

  it "has an associated polling_station" do
    expect(closure.polling_station).to be_a(Decidim::Votings::PollingStation)
  end

  it "has an associated polling_officer" do
    expect(closure.polling_officer).to be_a(Decidim::Votings::PollingOfficer)
  end

  context "with results" do
    before do
      closure.results << build_list(:election_result, 3, closurable: closure)
    end

    it "has many associated results" do
      expect(closure.results.first).to be_a(Decidim::Elections::Result)
      expect(closure.results.size).to eq(3)
    end
  end
end
