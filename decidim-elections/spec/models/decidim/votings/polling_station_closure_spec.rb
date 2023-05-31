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
      closure.results << build_list(:election_result, 3, closurable: closure, election: closure.election)
    end

    it "has many associated results" do
      expect(closure.results.first).to be_a(Decidim::Elections::Result)
      expect(closure.results.size).to eq(3)
    end

    it "the results have an associated bulletin board closure" do
      expect(closure.results.first.closurable).to be_a(Decidim::Votings::PollingStationClosure)
    end
  end

  describe "#signed?" do
    let(:closure) { create(:ps_closure, signed_at:) }

    context "when signed_at is blank" do
      let(:signed_at) { nil }

      it "returns false" do
        expect(closure.signed?).to be false
      end
    end

    context "when signed_at is present" do
      let(:signed_at) { Time.current }

      it "returns true" do
        expect(closure.signed?).to be true
      end
    end
  end
end
