# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::BulletinBoardClosure, type: :model do
  subject(:closure) { build(:bb_closure) }

  it { is_expected.to be_valid }

  it "has an associated election" do
    expect(closure.election).to be_a(Decidim::Elections::Election)
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
