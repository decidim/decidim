# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::TrusteeZone::UpdateElectionBulletinBoardStatus do
  subject { described_class.new(election, required_status) }

  let(:election) { create :election, :key_ceremony }
  let(:required_status) { :key_ceremony }
  let(:new_status) { :key_ceremony_ended }
  let(:response) { new_status }

  before do
    allow(Decidim::Elections.bulletin_board).to receive(:get_election_status).and_return(response)
  end

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "updates the election status" do
    subject.call
    expect(election).to be_bb_key_ceremony_ended
  end

  context "when the election status doesn't match the required status" do
    let(:election) { create :election, :tally_ended }

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "doesn't update the election status" do
      subject.call
      expect(election).to be_bb_tally_ended
    end
  end
end
